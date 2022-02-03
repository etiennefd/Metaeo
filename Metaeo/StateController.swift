//
//  StateController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-17.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit
import MapKit

struct DonneesPourLieu {
  var lieu: CLPlacemark
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
  
  init(_ lieu: CLPlacemark) {
    self.lieu = lieu
  }
}

// Classe pour contrôler l'état général de l'app

class StateController: NSObject {
  
  //MARK: Properties
  
  var window: UIWindow?
  
  // Concurrency
  let dispatchGroup = DispatchGroup()
  
  // Spécifiques à certaines sources de données
  let cleAPIOpenWeatherMap = ProcessInfo.processInfo.environment["cleAPIOpenWeatherMap"]!
  lazy var localisateurEC = LocalisateurEnvironnementCanada()
  
  // Données importées qui peuvent être utilisées dans les dans l'app
  var toutesLesDonneesImportees = [CLPlacemark : DonneesPourLieu]()
  
  // Géographie
  var locationManager = CLLocationManager()
//  var lieuUtilisateur: CLLocation = CLLocation(latitude: 45.52, longitude: -73.58)
  var lieuUtilisateur: CLLocation = CLLocation(latitude: 45.52, longitude: 73.58)
  var lieuEnAffichage: CLPlacemark? // contient les infos du lieu
  
  // Variables pour les unités de mesure choisies par l'utilisateur
  // à faire : remplacer les défauts selon la locale de l'utilisateur
  var uniteTemperature: UnitTemperature = .celsius
  var uniteDistance: UnitLength = .kilometers
  var uniteVitesseVent: UnitSpeed = .kilometersPerHour
  var unitePression: UnitPressure = .kilopascals
  
  var measurementFormatter: MeasurementFormatter {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.numberFormatter.maximumFractionDigits = 0
    return formatter
  }
  
  var doitRechargerListePrevision = false // pour recharger après avoir changé les unités
  
  // Variables pour l'affichage
  var modeSombre: UIUserInterfaceStyle = .unspecified
  
  func changeModeSombre(_ modeSombre: UIUserInterfaceStyle) {
    self.modeSombre = modeSombre
    if #available(iOS 13.0, *) {
      self.window?.overrideUserInterfaceStyle = modeSombre
    } else {
      // Fallback on earlier versions
    }
  }
  
  //MARK: Chaines pour l'interface
  
  func donneChaineTemperatureConvertie(_ mesure: Measurement<UnitTemperature>?) -> String {
    guard let mesure = mesure else {
      return "N/A"
    }
    let mesureConvertie = mesure.converted(to: self.uniteTemperature)
    var chaine = measurementFormatter.string(from: mesureConvertie)
    chaine = chaine.replacingOccurrences(of: "-0", with: "0")
    return chaine
  }
  
  func donneChaineDistanceConvertie(_ mesure: Measurement<UnitLength>) -> String {
    let mesureConvertie = mesure.converted(to: self.uniteDistance)
    return measurementFormatter.string(from: mesureConvertie)
  }
  
  func donneChaineVitesseConvertie(_ mesure: Measurement<UnitSpeed>) -> String {
    let mesureConvertie = mesure.converted(to: self.uniteVitesseVent)
    return measurementFormatter.string(from: mesureConvertie)
  }
  
  func donneChainePressionConvertie(_ mesure: Measurement<UnitPressure>) -> String {
    let mesureConvertie = mesure.converted(to: self.unitePression)
    let measurementFormatter = self.measurementFormatter
    switch self.unitePression {
    case .kilopascals, .inchesOfMercury, .poundsForcePerSquareInch:
      measurementFormatter.numberFormatter.maximumFractionDigits = 1
    case .atmosphere:
      measurementFormatter.numberFormatter.maximumFractionDigits = 4
    default:
      measurementFormatter.numberFormatter.maximumFractionDigits = 0
    }
    return measurementFormatter.string(from: mesureConvertie)
  }
  
  func donneChaineVent(_ prevision: Prevision) -> String? {
    let chaineDirectionVent = prevision.donneDirectionVent() != nil ? "\(prevision.donneDirectionVent()!.rawValue)" : ""
    if let vitesseVent = prevision.vitesseVent {
      if let vitesseVentMax = prevision.vitesseVentMax {
        let chaineVitesseVentSansUnite = String(Int(vitesseVent.converted(to: self.uniteVitesseVent).value.rounded()))
        let chaineVitesseVentMax = donneChaineVitesseConvertie(vitesseVentMax)
        if (chaineVitesseVentSansUnite != chaineVitesseVentMax) {
          return "\(chaineVitesseVentSansUnite)-\(chaineVitesseVentMax) \(chaineDirectionVent)"
        }
      }
      return "\(donneChaineVitesseConvertie(vitesseVent)) \(chaineDirectionVent)"
    }
    return nil
  }
  
  //MARK: Importation des données
  
  // Fonction avec completion handler qui va chercher les données
  
  func importeDonneesPourLieu(_ lieu: CLPlacemark, completionHandler: @escaping (DonneesPourLieu) -> Void) {
    // 1. créer la struct qui va contenir les données
    var donneesImportees = DonneesPourLieu(lieu)

    // 1.5 déterminer la localisation (ou alors mettre ça en paramètre?)
//    guard let lieu = lieuEnAffichage else {
//      return
//    }
    
    // 2. obtenir les services météo pertinents pour cette localisation
    let sources = sourcesPourLieu(lieu)
    
    // 3. boucle pour importer les données de chaque source
    for source in sources {
      guard let url = urlPourSource(source, lieu: lieu) else {
        continue
      }
     
      self.dispatchGroup.enter()
      
      // Requête HTTPS avec header
      var request = URLRequest(url: url)
      request.addValue("Metaeo https://github.com/etiennefd/Metaeo", forHTTPHeaderField: "User-Agent")
      
      let format = formatPourSource(source)
      switch format {
      case .xml:
        guard let delegueParseurXML = self.delegueParseurXMLPourSource(source) else {
          continue
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue du côté client lors de l'importation de \(source)")
            //self.handleClientError(error)
            self.dispatchGroup.leave()
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue du côté serveur (code HTTP pas dans les 200) lors de l'importation de \(source)")
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
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue du côté client lors de l'importation de \(source)")
            //self.handleClientError(error)
            self.dispatchGroup.leave()
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            print(error ?? "Erreur inconnue du côté serveur (code HTTP pas dans les 200) lors de l'importation de \(source)")
            
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
    guard let lieu = self.lieuEnAffichage else {
      return nil
    }
    return self.toutesLesDonneesImportees[lieu]
  }
  
  // Donne les services météo qui s'appliquent à une localisation donnée
  private func sourcesPourLieu(_ lieu: CLPlacemark) -> [SourcePrevision] {
    let sourcesMondeEntier: [SourcePrevision] = [.yrNo, .openWeatherMap]
    var sourcesPays: [SourcePrevision]
    switch lieu.country {
    case "Canada":
      sourcesPays = [.environnementCanada]
    case "United States":
      sourcesPays = [.NOAA]
    default:
      sourcesPays = []
    }
    return sourcesMondeEntier + sourcesPays
  }
  
  // Donne l'URL de la source de données pour la localisation donnée
  // À mettre à jour avec diverses sources, la localisation, etc.
  private func urlPourSource(_ source: SourcePrevision, lieu: CLPlacemark) -> URL? {
    // Obtenir les coordonnées
    guard let latitude = lieu.location?.coordinate.latitude,
          let longitude = lieu.location?.coordinate.longitude else {
      return nil
    }
    
    // Arrondir les coordonnées à quatre décimales
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = NumberFormatter.Style.decimal
    formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
    formatter.maximumFractionDigits = 4
    let latitudeArrondie = formatter.string(from: latitude as NSNumber)!
    let longitudeArrondie = formatter.string(from: longitude as NSNumber)!
    
    // Obtenir l'URL selon la source
    switch source {
    case .environnementCanada:
      return URL(string: localisateurEC.obtenirURLPour(latitude: latitude, longitude: longitude))
//      return URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/QC/s0000635_e.xml")! // Montréal
//      return URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/BC/s0000141_e.xml")! // Vancouver
    case .yrNo:
      return URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=\(latitudeArrondie)&lon=\(longitudeArrondie)")!
//      return URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=45.5088&lon=-73.5878")! // Montréal
    case .NOAA:
      return URL(string: "https://api.weather.gov/points/\(latitudeArrondie),\(longitudeArrondie)")!
//      return URL(string: "https://api.weather.gov/points/44.4759,-73.2121")! // Burlington
      //return URL(string: "https://api.weather.gov/points/44,-73")! //
    case .openWeatherMap:
      return URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitudeArrondie)&lon=\(longitudeArrondie)&units=metric&appid=\(cleAPIOpenWeatherMap)")!
//      return URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=45.5088&lon=-73.5878&units=metric&appid=\(cleAPIOpenWeatherMap)")! // Montréal
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
  
  func obtenirLieuDepuisLieuUtilisateur(completion: @escaping () -> Void) {
    if let lieu = locationManager.location {
      lieuUtilisateur = lieu
      lieuUtilisateur.obtenirLieu { lieu, error in
        guard let lieu = lieu, error == nil else {
          completion()
          return
        }
        self.lieuEnAffichage = lieu
//        print(lieu.locality ?? "no locality")
//        print(lieu.subLocality ?? "no sublocality")
//        print(lieu.administrativeArea ?? "no admin area")
//        print(lieu.subAdministrativeArea ?? "no subadmin area")
//        print(lieu.country ?? "no country")
//        print(lieu.isoCountryCode ?? "no iso code")
        completion()
      }
    }
  }
}

// Extension pour déterminer la localisation de l'utilisateur
extension StateController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse {
      locationManager.requestLocation()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.first {
      print("location: \(location)")
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("error:: (error)")
  }
}
