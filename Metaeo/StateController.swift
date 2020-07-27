//
//  StateController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-17.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

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

// Classe pour contrôler l'état général de l'app

class StateController {
  
  //MARK: Properties
  
  let dispatchGroup = DispatchGroup()
  
  let cleAPIOpenWeatherMap = ProcessInfo.processInfo.environment["cleAPIOpenWeatherMap"]!
  
  // Données importées qui peuvent être utilisées dans les dans l'app
  var toutesLesDonneesImportees = [String : DonneesPourLieu]() // changer le String pour le type approprié pour les lieux
  var lieuEnSelection: String? = "Montreal"
  
  // variables pour les paramètres
  // var uniteTemperature etc.
  
  //MARK: Importation des données
  
  // Fonction avec completion handler qui va chercher les données
  
  func importeDonneesPourLieu(_ lieu: String, completionHandler: @escaping (DonneesPourLieu) -> Void) {
    // 1. créer la struct qui va contenir les données
    var donneesImportees = DonneesPourLieu()

    // 1.5 déterminer la localisation (ou alors mettre ça en paramètre?)
    let lieu = lieuEnSelection ?? "Montreal"
    
    // 2. obtenir les services météo pertinents pour cette localisation
    let sources = sourcesPourLieu(lieu)
    
    // 3. boucle pour importer les données de chaque source
    for source in sources {
      guard let url = urlPourSource(source, lieu: lieu) else {
        continue
      }
      self.dispatchGroup.enter()
      let format = formatPourSource(source)
      switch format {
      case .xml:
        guard let delegueParseurXML = self.delegueParseurXMLPourSource(source) else {
          continue
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue")
            //self.handleClientError(error)
            self.dispatchGroup.leave()
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue")
              //self.handleServerError(response)
              self.dispatchGroup.leave()
              return
          }
          // Parser le xml
          let parser = XMLParser(data: data)
          parser.delegate = delegueParseurXML
          if parser.parse() {
            //print(delegueParseurXML.previsionsParJour ?? "No results")
          }
          
          // Mettre à jour la struct de données
          if let conditionsActuelles = delegueParseurXML.conditionsActuelles {
            donneesImportees.conditionsActuelles[source] = conditionsActuelles
          }
          if let previsionsParJour = delegueParseurXML.previsionsParJour {
            donneesImportees.previsionsParJour[source] = previsionsParJour
          }
          if let previsionsParHeure = delegueParseurXML.previsionsParHeure {
            donneesImportees.previsionsParHeure[source] = previsionsParHeure
          }
          donneesImportees.heureLeverDuSoleil = delegueParseurXML.heureLeverDuSoleil
          donneesImportees.heureCoucherDuSoleil = delegueParseurXML.heureCoucherDuSoleil
          donneesImportees.heureEmission = delegueParseurXML.heureCreationXML
          donneesImportees.fuseauHoraire = delegueParseurXML.fuseauHoraire
          self.dispatchGroup.leave()
        }
        task.resume()
        
      case .json:
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue")
            //self.handleClientError(error)
            self.dispatchGroup.leave()
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue")
              //self.handleServerError(response)
              self.dispatchGroup.leave()
              return
          }
          // Parser le JSON
          guard let parseur = self.parseurJSONPourSource(source) else {
            self.dispatchGroup.leave()
            return
          }
          do {
            let json = try JSON(data: data)
            parseur.parseJSON(json) { conditionsActuelles, previsionsParJour, previsionsParHeure in
              // Mettre à jour les données à afficher
              if let conditionsActuelles = conditionsActuelles {
                donneesImportees.conditionsActuelles[source] = conditionsActuelles
              }
              if let previsionsParJour = previsionsParJour {
                donneesImportees.previsionsParJour[source] = previsionsParJour
              }
              if let previsionsParHeure = previsionsParHeure {
                donneesImportees.previsionsParHeure[source] = previsionsParHeure
              }
              // coucher de soleil, etc.?
              self.dispatchGroup.leave()
            }
          } catch {
            // erreur
            self.dispatchGroup.leave()
          }          
        }
        task.resume()
        
//      default:
//        break
      }
      
    }
    // 4. appeler le completionHandler avec la struct de données complétée, mais seulement après que toutes les tâches du dispatchGroup sont finies
    self.dispatchGroup.notify(queue: .main) {
      self.toutesLesDonneesImportees[lieu] = donneesImportees
      completionHandler(donneesImportees)
    }
  }
  
  func donneDonneesPourLieuEnAffichage() -> DonneesPourLieu? {
    guard let lieu = self.lieuEnSelection else {
      return nil
    }
    return self.toutesLesDonneesImportees[lieu]
  }
  
  // Donne les services météo qui s'appliquent à une localisation donnée
  private func sourcesPourLieu(_ lieu: String) -> [SourcePrevision] {
    if lieu == "Montreal" {
      return [.environnementCanada, .yrNo, .NOAA, /* utilise présentement les données de Burlington */ .openWeatherMap]
    }
    return []
  }
  
  // Donne l'URL de la source de données pour la localisation donnée
  // À mettre à jour avec diverses sources, la localisation, etc.
  private func urlPourSource(_ source: SourcePrevision, lieu: String?) -> URL? {
    switch source {
    case .environnementCanada:
      return URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/QC/s0000635_e.xml")!
    case .yrNo:
      return URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=45.5088&lon=-73.5878&altitude=216")!
    case .NOAA:
      return URL(string: "https://api.weather.gov/points/44.4759,-73.2121")! // Burlington
      //return URL(string: "https://api.weather.gov/points/44,-73")! //
    case .openWeatherMap:
      return URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=45.5088&lon=-73.5878&units=metric&appid=\(cleAPIOpenWeatherMap)")!
    default:
      return nil
    }
  }
  
  // Donne le bon délégué parseur XML selon le type de données XML à parser
  private func delegueParseurXMLPourSource(_ source: SourcePrevision) -> DelegueParseurXML? {
    switch source {
    case .environnementCanada:
      return DelegueParseurXMLEnvironnementCanada()
    default:
      return nil
    }
  }
  
  // Donne le bon parseur JSON selon le type de données JSON à parser
  private func parseurJSONPourSource(_ source: SourcePrevision) -> ParseurJSON? {
    switch source {
    case .yrNo:
      return ParseurJSONYrNo()
    case .NOAA:
      return ParseurJSONNOAA()
    case .openWeatherMap:
      return ParseurJSONOpenWeatherMap()
    default:
      return nil
    }
  }
}
