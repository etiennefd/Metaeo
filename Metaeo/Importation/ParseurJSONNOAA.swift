//
//  ParseurJSONYrNo.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-04.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ParseurJSONNOAA: ParseurJSON {
  
  var conditionsActuelles: Prevision?
  var previsionsParJour: [Date : Prevision]!
  var previsionsParHeure: [Date : Prevision]!
  
  func parseJSON(_ json: JSON) {
    self.conditionsActuelles = Prevision()
    self.previsionsParHeure = [Date : Prevision]()
    self.previsionsParJour = [Date : Prevision]()
    
    let urlForecast = json["properties"]["forecast"].stringValue
    let urlForecastHourly = json["properties"]["forecastHourly"].stringValue
    let urlStations = json["properties"]["observationStations"].stringValue
    
    // 1. Importer le JSON des prévisions par jour (ex. https://api.weather.gov/gridpoints/LWX/96,70/forecast)
    
    let taskForecast = URLSession.shared.dataTask(with: URL(string: urlForecast)!) { data, response, error in
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
      let parseur = ParseurJSONNOAAForecast()
      do {
        let json = try JSON(data: data)
        parseur.parseJSON(json)
      } catch {
        // erreur
      }
      // Mettre à jour les données à afficher
      DispatchQueue.main.async {
        if let previsionsParJour = parseur.previsionsParJour {
          self.previsionsParJour = previsionsParJour
        }
      }
    }
    taskForecast.resume()
    
    // 2. Importer le JSON des prévisions par heure (ex. https://api.weather.gov/gridpoints/LWX/96,70/forecast/hourly)
    
    let taskForecastHourly = URLSession.shared.dataTask(with: URL(string: urlForecastHourly)!) { data, response, error in
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
      let parseur = ParseurJSONNOAAForecastHourly()
      do {
        let json = try JSON(data: data)
        parseur.parseJSON(json)
      } catch {
        // erreur
      }
      // Mettre à jour les données à afficher
      DispatchQueue.main.async {
        if let previsionsParHeure = parseur.previsionsParHeure {
          self.previsionsParHeure = previsionsParHeure
        }
      }
    }
    taskForecastHourly.resume()
    
    // 3. mporter le JSON des stations, qui servira lui-même à importer le JSON des dernières observations
    // (ex. https://api.weather.gov/gridpoints/BTV/88,56/stations suivi de https://api.weather.gov/stations/KBTV/observations/latest)
    
    let taskStations = URLSession.shared.dataTask(with: URL(string: urlStations)!) { data, response, error in
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
      let parseur = ParseurJSONNOAAStations()
      do {
        let json = try JSON(data: data)
        parseur.parseJSON(json)
      } catch {
        // erreur
      }
      // Mettre à jour les données à afficher
      DispatchQueue.main.async {
        if let urlObservations = parseur.urlObservations {
          let taskObservations = URLSession.shared.dataTask(with: URL(string: urlObservations)!) { data, response, error in
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
            let parseur = ParseurJSONNOAAObservations()
            do {
              let json = try JSON(data: data)
              parseur.parseJSON(json)
            } catch {
              // erreur
            }
            // Mettre à jour les données à afficher
            DispatchQueue.main.async {
              if let conditionsActuelles = parseur.conditionsActuelles {
                self.conditionsActuelles = conditionsActuelles
              }
            }
          }
          taskObservations.resume()
        }
      }
    }
    taskStations.resume()

  }
}

class ParseurJSONNOAAForecast {
  var previsionsParJour: [Date : Prevision]!
  
  func parseJSON(_ json: JSON) {
    self.previsionsParJour = [Date : Prevision]()
    
    // aller chercher les infos
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    let heureEmission = dateFormatter.date(from: json["properties"]["updated"].stringValue)
    
    let periods = json["properties"]["periods"].arrayValue
    for objetPrevision in periods {
      // Obtenir l'heure de la prévision
      guard let heurePrevision = dateFormatter.date(from: objetPrevision["startTime"].stringValue) else {
        continue
      }
      // à faire : modifier si ce n'est pas 18h ou 6h
      
      // Créer la prévision
      var previsionEnEdition = Prevision()
      previsionEnEdition.type = .quotidien
      previsionEnEdition.source = .NOAA
      previsionEnEdition.heureDebut = heurePrevision
      previsionEnEdition.heureEmission = heureEmission

      let heureFinPrevision = dateFormatter.date(from: objetPrevision["endTime"].stringValue)
      previsionEnEdition.heureFin = heureFinPrevision
      previsionEnEdition.chainePeriode = objetPrevision["name"].stringValue
      previsionEnEdition.nuit = objetPrevision["isDaytime"].boolValue
      previsionEnEdition.temperature = fahrenheitVersCelsius(objetPrevision["temperature"].doubleValue)
      
      var chaineVitesseVent = objetPrevision["windSpeed"].stringValue
      chaineVitesseVent = chaineVitesseVent.replacingOccurrences(of: " mph", with: "")
      let composants = chaineVitesseVent.components(separatedBy: " to ")
      if composants.count >= 1, let vitesseVent = Double(composants[0]) {
        previsionEnEdition.vitesseVent = mphVersKmh(vitesseVent)
      }
      if composants.count >= 2, let vitesseVentMax = Double(composants[1]) {
        previsionEnEdition.vitesseVentMax = mphVersKmh(vitesseVentMax)
      }
      previsionEnEdition.directionVent = PointCardinal(rawValue: objetPrevision["windDirection"].stringValue)
      
      let chaineCondition = nettoyerChaineCondition(objetPrevision["shortForecast"].stringValue)
      previsionEnEdition.condition = Condition(rawValue: chaineCondition)
      if previsionEnEdition.condition == nil {
        print("Incapable de parser la condition \(chaineCondition)")
      }
      previsionEnEdition.detailsCondition = objetPrevision["detailedForecast"].stringValue
      
      // Ajouter la prévision
      self.previsionsParJour[heurePrevision] = previsionEnEdition
    }
  }
}

class ParseurJSONNOAAForecastHourly {
  var previsionsParHeure: [Date : Prevision]!
  
  func parseJSON(_ json: JSON) {
    self.previsionsParHeure = [Date : Prevision]()
    
    // aller chercher les infos
  }
}

class ParseurJSONNOAAStations {
  var urlObservations: String?
  
  func parseJSON(_ json: JSON) {
    let listeStations = json["features"].arrayValue
    let stationLaPlusProche = listeStations[0]
    let urlStation = stationLaPlusProche["id"].stringValue
    self.urlObservations = "\(urlStation)/observations/latest"
  }
}

class ParseurJSONNOAAObservations {
  var conditionsActuelles: Prevision!
  
  func parseJSON(_ json: JSON) {
    self.conditionsActuelles = Prevision()
    
    // aller chercher les infos
  }
}

// Mettre une condition en minuscules
private func nettoyerChaineCondition(_ chaine: String) -> String {
  let chaineNettoyee = chaine.lowercased()
//  chaineNettoyee = chaineNettoyee.trimmingCharacters(in: .whitespaces)
//  if chaineNettoyee.last == "." {
//    chaineNettoyee = String(chaineNettoyee.dropLast())
//  }
  return chaineNettoyee
}
