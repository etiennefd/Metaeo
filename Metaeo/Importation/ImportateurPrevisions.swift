//
//  ImportateurPrevisions.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-23.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ImportateurPrevisions {
  static let global: ImportateurPrevisions = ImportateurPrevisions()
  
  // Données importées qui peuvent être utilisées partout dans l'app
  var conditionsActuelles: Prevision!
  var previsionsParJour = [SourcePrevision : [String : Prevision]]()// changer String pour Date?
  var previsionsParHeure = [SourcePrevision : [String : Prevision]]() // changer String pour Date?
  
  func importePrevisions() {
    // 1. appeler une fonction pour déterminer la localisation (ou alors mettre ça en paramètre de importePrevisions()?)
    let localisation = "Montreal"
    
    // 2. obtenir les services météo pertinents pour cette localisation
    let sources = sourcesPourLocalisation(localisation)
    
    // 3. boucle pour importer les données de chaque source
    for source in sources {
      guard let url = urlPourSource(source, localisation: localisation) else {
        continue
      }
      let delegueParseurXML = delegueParseurXMLPourSource(source)
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
          //print(delegueParseurXML.previsionsParPeriode ?? "No results")
        }
        
        // Mettre à jour l'affichage
        DispatchQueue.main.async {
          if let conditionsActuelles = delegueParseurXML.conditionsActuelles {
            self.conditionsActuelles = conditionsActuelles
          }
          if let previsionsParJour = delegueParseurXML.previsionsParJour {
            self.previsionsParJour[source] = previsionsParJour
          }
          if let previsionsParHeure = delegueParseurXML.previsionsParHeure {
            self.previsionsParHeure[source] = previsionsParHeure
          }
          self.previsionsParJour[source] = delegueParseurXML.previsionsParJour
          self.previsionsParHeure[source] = delegueParseurXML.previsionsParHeure
        }
      }
      task.resume()
    }
  }
  
  // Donne les services météo qui s'appliquent à une localisation donnée
  private func sourcesPourLocalisation(_ localisation: String) -> [SourcePrevision] {
    if localisation == "Montreal" {
      return [.environnementCanada, .yrNo]
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
      return URL(string: "https://www.yr.no/place/Canada/Quebec/Montreal/forecast.xml")!
    default:
      return nil
    }
  }
  
  // Donne le bon délégué parseur XML selon le type de données XML à parser
  private func delegueParseurXMLPourSource(_ source: SourcePrevision) -> DelegueParseurXML {
    return DelegueParseurXML()
  }
}
