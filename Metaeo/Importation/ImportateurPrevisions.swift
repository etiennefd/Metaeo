//
//  ImportateurPrevisions.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-23.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

enum FormatDonnees {
  case xml, json
}

struct DonneesPourLieu {
  var heureEmission: Date?
  // var coordonnées
  // var nom du lieu
  // var ville
  // var province
  // var pays
  var fuseauHoraire: TimeZone?
  
  var conditionsActuelles = [SourcePrevision : Prevision]()
  var previsionsParJour = [SourcePrevision : [Date : Prevision]]()
  var previsionsParHeure = [SourcePrevision : [Date : Prevision]]()
  var heureLeverDuSoleil: Date?
  var heureCoucherDuSoleil: Date?
}

class ImportateurPrevisions {
  static let global: ImportateurPrevisions = ImportateurPrevisions()
  
  // Données importées qui peuvent être utilisées partout dans l'app
  var toutesLesDonneesImportees = [DonneesPourLieu]()
  var donneesEnAffichage = DonneesPourLieu()
  var sourceChoisieConditionsActuelles: SourcePrevision?
  
  func importePrevisions() {
    // 1. appeler une fonction pour déterminer la localisation (ou alors mettre ça en paramètre de importePrevisions()?)
    let localisation = "Montreal"
    
    // 2. obtenir les services météo pertinents pour cette localisation
    let sources = sourcesPourLocalisation(localisation)
    
    // 3. boucle pour importer les données de chaque source
    for (source, format) in sources {
      guard let url = urlPourSource(source, localisation: localisation) else {
        continue
      }
      switch format {
      case .xml:
        let delegueParseurXML = self.delegueParseurXMLPourSource(source)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue")
            //self.handleClientError(error)
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue")
              //self.handleServerError(response)
              return
          }
          // Parser le xml
          let parser = XMLParser(data: data)
          parser.delegate = delegueParseurXML
          if parser.parse() {
            //print(delegueParseurXML.previsionsParJour ?? "No results")
          }
          
          // Mettre à jour les données à afficher
          DispatchQueue.main.async {
//            if self.donneesEnAffichage == nil {
//              self.donneesEnAffichage = DonneesPourLieu()
//            }
            if let conditionsActuelles = delegueParseurXML.conditionsActuelles {
              self.donneesEnAffichage.conditionsActuelles[source] = conditionsActuelles
            }
            if let previsionsParJour = delegueParseurXML.previsionsParJour {
              self.donneesEnAffichage.previsionsParJour[source] = previsionsParJour
            }
            if let previsionsParHeure = delegueParseurXML.previsionsParHeure {
              self.donneesEnAffichage.previsionsParHeure[source] = previsionsParHeure
            }
            self.donneesEnAffichage.previsionsParJour[source] = delegueParseurXML.previsionsParJour
            self.donneesEnAffichage.previsionsParHeure[source] = delegueParseurXML.previsionsParHeure
            self.donneesEnAffichage.heureLeverDuSoleil = delegueParseurXML.heureLeverDuSoleil
            self.donneesEnAffichage.heureCoucherDuSoleil = delegueParseurXML.heureCoucherDuSoleil
            self.donneesEnAffichage.heureEmission = delegueParseurXML.heureCreationXML
            self.donneesEnAffichage.fuseauHoraire = delegueParseurXML.fuseauHoraire
            
            // Pour le moment le choix de la source est un peu aléatoire selon la première tâche terminée... il va falloir améliorer ça
            if self.sourceChoisieConditionsActuelles == nil {
              self.sourceChoisieConditionsActuelles = source
            }
          }
        }
        task.resume()
        
      case .json:
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue")
            //self.handleClientError(error)
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue")
              //self.handleServerError(response)
              return
          }
          // Parser le JSON
          let parseur = self.parseurJSONPourSource(source)
          do {
            let json = try JSON(data: data)
            parseur.parseJSON(json)
          } catch {
            // erreur
          }
          // Mettre à jour les données à afficher
          DispatchQueue.main.async {
//            self.donneesEnAffichage = DonneesPourLieu()
//            if let conditionsActuelles = parseur.conditionsActuelles {
//              self.donneesEnAffichage.conditionsActuelles[source] = conditionsActuelles
//            }
            if let previsionsParJour = parseur.previsionsParJour {
              self.donneesEnAffichage.previsionsParJour[source] = previsionsParJour
            }
            if let previsionsParHeure = parseur.previsionsParHeure {
              self.donneesEnAffichage.previsionsParHeure[source] = previsionsParHeure
            }
            self.donneesEnAffichage.previsionsParJour[source] = parseur.previsionsParJour
            self.donneesEnAffichage.previsionsParHeure[source] = parseur.previsionsParHeure
//            self.donneesEnAffichage.heureLeverDuSoleil = parseur.heureLeverDuSoleil
//            self.donneesEnAffichage.heureCoucherDuSoleil = parseur.heureCoucherDuSoleil
//            self.donneesEnAffichage.heureEmission = parseur.heureCreationXML
//            if self.sourceChoisieConditionsActuelles == nil {
//              self.sourceChoisieConditionsActuelles = source
//            }
          }
        }
        
        task.resume()
        
      default:
        break
      }
    }
  }
  
  // Donne les services météo qui s'appliquent à une localisation donnée
  private func sourcesPourLocalisation(_ localisation: String) -> [(SourcePrevision, FormatDonnees)] {
    if localisation == "Montreal" {
      return [(.environnementCanada, .xml), (.yrNo, .json)]
    }
    return []
  }
  
  // Donne l'URL de la source de données pour la localisation donnée
  // À mettre à jour avec divers services, la localisation, etc.
  private func urlPourSource(_ source: SourcePrevision, localisation: String?) -> URL? {
    switch source {
    case .environnementCanada:
      return URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/QC/s0000635_e.xml")!
    case .yrNo:
      //return URL(string: "https://www.yr.no/place/Canada/Quebec/Montreal/forecast.xml")! ancien url
      return URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=45.5088&lon=-73.5878&altitude=216")!
    default:
      return nil
    }
  }
  
  // Donne le bon délégué parseur XML selon le type de données XML à parser
  private func delegueParseurXMLPourSource(_ source: SourcePrevision) -> DelegueParseurXMLEnvironnementCanada {
    return DelegueParseurXMLEnvironnementCanada()
  }
  
  private func parseurJSONPourSource(_ source: SourcePrevision) -> ParseurJSONYrNo {
    return ParseurJSONYrNo()
  }

}
