////
////  ImportateurPrevisions.swift
////  Metaeo
////
////  Created by Étienne Fortier-Dubois on 20-06-23.
////  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
////
//
//import Foundation
//
//struct DonneesPourLieu {
//  var heureEmission: Date?
//  // var coordonnées
//  // var nom du lieu
//  // var ville
//  // var province
//  // var pays
//  var fuseauHoraire: TimeZone?
//
//  var conditionsActuelles = [SourcePrevision : Prevision]()
//  var previsionsParJour = [SourcePrevision : [Date : Prevision]]()
//  var previsionsParHeure = [SourcePrevision : [Date : Prevision]]()
//  var heureLeverDuSoleil: Date?
//  var heureCoucherDuSoleil: Date?
//}
//
//class ImportateurPrevisions {
//  static let global: ImportateurPrevisions = ImportateurPrevisions()
//
//  // Données importées qui peuvent être utilisées partout dans l'app
//  var toutesLesDonneesImportees = [DonneesPourLieu]()
//  var donneesEnAffichage = DonneesPourLieu() // à recréer au moment de changer de lieu
//  var sourceChoisieConditionsActuelles: SourcePrevision?
//
//  func importePrevisions() {
//    // 1. appeler une fonction pour déterminer la localisation (ou alors mettre ça en paramètre de importePrevisions()?)
//    let localisation = "Montreal"
//
//    // 2. obtenir les services météo pertinents pour cette localisation
//    let sources = sourcesPourLocalisation(localisation)
//
//    // 3. boucle pour importer les données de chaque source
//    for source in sources {
//      guard let url = urlPourSource(source, localisation: localisation) else {
//        continue
//      }
//      let format = formatPourSource(source)
//      switch format {
//      case .xml:
//        guard let delegueParseurXML = self.delegueParseurXMLPourSource(source) else {
//          return
//        }
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//          guard let data = data, error == nil else {
//            print(error ?? "Erreur inconnue")
//            //self.handleClientError(error)
//            return
//          }
//          guard let httpResponse = response as? HTTPURLResponse,
//            (200...299).contains(httpResponse.statusCode) else {
//              print(error ?? "Erreur inconnue")
//              //self.handleServerError(response)
//              return
//          }
//          // Parser le xml
//          let parser = XMLParser(data: data)
//          parser.delegate = delegueParseurXML
//          if parser.parse() {
//            //print(delegueParseurXML.previsionsParJour ?? "No results")
//          }
//
//          // Mettre à jour les données à afficher
//          DispatchQueue.main.async {
//            if let conditionsActuelles = delegueParseurXML.conditionsActuelles {
//              self.donneesEnAffichage.conditionsActuelles[source] = conditionsActuelles
//            }
//            if let previsionsParJour = delegueParseurXML.previsionsParJour {
//              self.donneesEnAffichage.previsionsParJour[source] = previsionsParJour
//            }
//            if let previsionsParHeure = delegueParseurXML.previsionsParHeure {
//              self.donneesEnAffichage.previsionsParHeure[source] = previsionsParHeure
//            }
//            self.donneesEnAffichage.heureLeverDuSoleil = delegueParseurXML.heureLeverDuSoleil
//            self.donneesEnAffichage.heureCoucherDuSoleil = delegueParseurXML.heureCoucherDuSoleil
//            self.donneesEnAffichage.heureEmission = delegueParseurXML.heureCreationXML
//            self.donneesEnAffichage.fuseauHoraire = delegueParseurXML.fuseauHoraire
//
//            // Pour le moment le choix de la source est un peu aléatoire selon la première tâche terminée... il va falloir améliorer ça
//            if self.sourceChoisieConditionsActuelles == nil {
//              self.sourceChoisieConditionsActuelles = source
//            }
//          }
//        }
//        task.resume()
//
//      case .json:
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//          guard let data = data, error == nil else {
//            print(error ?? "Erreur inconnue")
//            //self.handleClientError(error)
//            return
//          }
//          guard let httpResponse = response as? HTTPURLResponse,
//            (200...299).contains(httpResponse.statusCode) else {
//              print(error ?? "Erreur inconnue")
//              //self.handleServerError(response)
//              return
//          }
//          // Parser le JSON
//          guard let parseur = self.parseurJSONPourSource(source) else {
//            return
//          }
//          do {
//            let json = try JSON(data: data)
//            parseur.parseJSON(json)
//          } catch {
//            // erreur
//          }
//          // Mettre à jour les données à afficher
//          DispatchQueue.main.async {
//            if let conditionsActuelles = parseur.conditionsActuelles {
//              self.donneesEnAffichage.conditionsActuelles[source] = conditionsActuelles
//            }
//            if let previsionsParJour = parseur.previsionsParJour {
//              self.donneesEnAffichage.previsionsParJour[source] = previsionsParJour
//            }
//            if let previsionsParHeure = parseur.previsionsParHeure {
//              self.donneesEnAffichage.previsionsParHeure[source] = previsionsParHeure
//            }
////            self.donneesEnAffichage.heureLeverDuSoleil = parseur.heureLeverDuSoleil
////            self.donneesEnAffichage.heureCoucherDuSoleil = parseur.heureCoucherDuSoleil
////            self.donneesEnAffichage.heureEmission = parseur.heureCreationXML
//
//            // À modifier pour mieux choisir la source (voir l'équivalent dans la section XML)
////            if self.sourceChoisieConditionsActuelles == nil {
////              self.sourceChoisieConditionsActuelles = source
////            }
//          }
//        }
//
//        task.resume()
//
//      default:
//        break
//      }
//    }
//  }
//
//  // Donne les services météo qui s'appliquent à une localisation donnée
//  private func sourcesPourLocalisation(_ localisation: String) -> [SourcePrevision] {
//    if localisation == "Montreal" {
//      return [.environnementCanada, .yrNo, .NOAA /* utilise présentement les données de Burlington */]
//    }
//    return []
//  }
//
//  // Donne l'URL de la source de données pour la localisation donnée
//  // À mettre à jour avec diverses sources, la localisation, etc.
//  private func urlPourSource(_ source: SourcePrevision, localisation: String?) -> URL? {
//    switch source {
//    case .environnementCanada:
//      return URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/QC/s0000635_e.xml")!
//    case .yrNo:
//      return URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=45.5088&lon=-73.5878&altitude=216")!
//    case .NOAA:
//      return URL(string: "https://api.weather.gov/points/44.4759,-73.2121")! // Burlington
//    default:
//      return nil
//    }
//  }
//
//  // Donne le bon délégué parseur XML selon le type de données XML à parser
//  private func delegueParseurXMLPourSource(_ source: SourcePrevision) -> DelegueParseurXML? {
//    switch source {
//    case .environnementCanada:
//      return DelegueParseurXMLEnvironnementCanada()
//    default:
//      return nil
//    }
//  }
//
//  // Donne le bon parseur JSON selon le type de données JSON à parser
//  private func parseurJSONPourSource(_ source: SourcePrevision) -> ParseurJSON? {
//    switch source {
//    case .yrNo:
//      return ParseurJSONYrNo()
//    case .NOAA:
//      return ParseurJSONNOAA()
//    default:
//      return nil
//    }
//  }
//
//}
