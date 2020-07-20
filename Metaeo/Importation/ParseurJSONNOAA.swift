//
//  ParseurJSONNOAAA.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-04.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ParseurJSONNOAA: ParseurJSON {
  
  let dateFormatter = DateFormatter()
  
  func parseJSON(_ json: JSON, completionHandler: @escaping (Prevision?, [Date : Prevision]?, [Date : Prevision]?) -> Void) {
    
    var conditionsActuelles = Prevision()
    var previsionsParHeure = [Date : Prevision]()
    var previsionsParJour = [Date : Prevision]()
    
    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    let urlForecast = json["properties"]["forecast"].stringValue
    let urlForecastHourly = json["properties"]["forecastHourly"].stringValue
    let urlStations = json["properties"]["observationStations"].stringValue
    
    let dispatchGroup = DispatchGroup()
    // il faut que cette fonction retourne uniquement une fois que tout a été parsé.
    
    // 1. Importer le JSON des prévisions par jour (ex. https://api.weather.gov/gridpoints/LWX/96,70/forecast)
    dispatchGroup.enter()
    let taskForecast = URLSession.shared.dataTask(with: URL(string: urlForecast)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue")
        //self.handleClientError(error)
        dispatchGroup.leave()
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print(error ?? "Erreur inconnue")
          //self.handleServerError(response)
          dispatchGroup.leave()
          return
      }
      // Parser le JSON
      do {
        let json = try JSON(data: data)
        previsionsParJour = self.parseJSONForecast(json)
      } catch {
        // erreur
      }
      dispatchGroup.leave()
    }
    taskForecast.resume()
    
    // 2. Importer le JSON des prévisions par heure (ex. https://api.weather.gov/gridpoints/LWX/96,70/forecast/hourly)
    dispatchGroup.enter()
    let taskForecastHourly = URLSession.shared.dataTask(with: URL(string: urlForecastHourly)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue")
        //self.handleClientError(error)
        dispatchGroup.leave()
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print(error ?? "Erreur inconnue")
          //self.handleServerError(response)
          dispatchGroup.leave()
          return
      }
      // Parser le JSON
      do {
        let json = try JSON(data: data)
        previsionsParHeure = self.parseJSONHourlyForecast(json)
      } catch {
        // erreur
      }
      dispatchGroup.leave()
    }
    taskForecastHourly.resume()
    
    // 3. importer le JSON des stations, qui servira lui-même à importer le JSON des dernières observations
    // (ex. https://api.weather.gov/gridpoints/BTV/88,56/stations suivi de https://api.weather.gov/stations/KBTV/observations/latest)
    dispatchGroup.enter()
    let taskStations = URLSession.shared.dataTask(with: URL(string: urlStations)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue")
        //self.handleClientError(error)
        dispatchGroup.leave()
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print(error ?? "Erreur inconnue")
          //self.handleServerError(response)
          dispatchGroup.leave()
          return
      }
      // Parser le JSON
      do {
        let json = try JSON(data: data)
        let urlObservations = self.parseJSONStations(json)
        
        // 4. À l'intérieur du completion handler de la tâche des stations, faire la tâche des observations
        dispatchGroup.enter()
        let taskObservations = URLSession.shared.dataTask(with: URL(string: urlObservations)!) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue")
            //self.handleClientError(error)
            dispatchGroup.leave()
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue")
              //self.handleServerError(response)
              dispatchGroup.leave()
              return
          }
          // Parser le JSON
          do {
            let json = try JSON(data: data)
            conditionsActuelles = self.parseJSONObservations(json)
          } catch {
            // erreur
          }
          dispatchGroup.leave()
        }
        taskObservations.resume()
      } catch {
        // erreur
      }
      dispatchGroup.leave()
    }
    taskStations.resume()

    // Appeler le completionHandler une fois que toutes les tâches ont été complétées
    dispatchGroup.notify(queue: .main) {
      completionHandler(conditionsActuelles, previsionsParJour, previsionsParHeure)
    }
  }
  
  func parseJSONForecast(_ json: JSON) -> [Date : Prevision] {
    var previsionsParJour = [Date : Prevision]()
    
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
      previsionsParJour[heurePrevision] = previsionEnEdition
    }
    
    return previsionsParJour
  }
  
  func parseJSONHourlyForecast(_ json: JSON) -> [Date : Prevision]{
    var previsionsParHeure = [Date : Prevision]()
    
    let heureEmission = dateFormatter.date(from: json["properties"]["updated"].stringValue)
    
    let periods = json["properties"]["periods"].arrayValue
    for objetPrevision in periods {
      // Obtenir l'heure de la prévision
      guard let heurePrevision = dateFormatter.date(from: objetPrevision["startTime"].stringValue) else {
        continue
      }
      
      // Créer la prévision
      var previsionEnEdition = Prevision()
      previsionEnEdition.type = .horaire
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
      previsionsParHeure[heurePrevision] = previsionEnEdition
    }
    
    return previsionsParHeure
  }
  
  func parseJSONStations(_ json: JSON) -> String {
    let listeStations = json["features"].arrayValue
    let stationLaPlusProche = listeStations[0]
    let urlStation = stationLaPlusProche["id"].stringValue
    return "\(urlStation)/observations/latest"
  }
  
  func parseJSONObservations(_ json: JSON) -> Prevision {
    var conditionsActuelles = Prevision()
    conditionsActuelles.type = .actuel
    conditionsActuelles.source = .NOAA
    
    let objetPrevision = json["properties"]

    let heureObservation = dateFormatter.date(from: objetPrevision["timestamp"].stringValue)
    conditionsActuelles.heureDebut = heureObservation
    conditionsActuelles.heureEmission = heureObservation
    
    let chaineCondition = nettoyerChaineCondition(objetPrevision["textDescription"].stringValue)
    conditionsActuelles.condition = Condition(rawValue: chaineCondition)
    if conditionsActuelles.condition == nil {
      print("Incapable de parser la condition \(chaineCondition)")
    }
    
    conditionsActuelles.temperature = objetPrevision["temperature"]["value"].doubleValue // déjà en Celsius
    conditionsActuelles.pointDeRosee = objetPrevision["dewpoint"]["value"].doubleValue // déjà en Celsius
    conditionsActuelles.directionVentDegres = objetPrevision["windDirection"]["value"].doubleValue
    conditionsActuelles.vitesseVent = objetPrevision["windSpeed"]["value"].doubleValue
    conditionsActuelles.vitesseRafales = objetPrevision["windGust"]["value"].doubleValue
    conditionsActuelles.pression = objetPrevision["barometricPressure"]["value"].doubleValue / 1000.0 // barometric ou sea level??? // divisé par 1000 car la valeur et en Pa
    conditionsActuelles.visibilite = objetPrevision["visibility"]["value"].doubleValue / 1000.0 // divisé par 1000 car la valeur est en m
    conditionsActuelles.humidite = objetPrevision["relativeHumidity"]["value"].doubleValue
    conditionsActuelles.humidex = objetPrevision["heatIndex"]["value"].doubleValue
    conditionsActuelles.refroidissementEolien = objetPrevision["windChill"]["value"].doubleValue
    
    return conditionsActuelles
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
