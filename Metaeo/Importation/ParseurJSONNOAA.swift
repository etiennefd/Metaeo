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
  let dispatchGroup = DispatchGroup() // pour s'assurer que le parseur retourne uniquement une fois que tout a été parsé.
  
  func parseJSON(_ json: JSON, completionHandler: @escaping (Prevision?, [Date : Prevision]?, [Date : Prevision]?) -> Void) {
    
    var conditionsActuelles = Prevision()
    var previsionsParHeure = [Date : Prevision]()
    var previsionsParJour = [Date : Prevision]()
    
    self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    let urlForecast = json["properties"]["forecast"].stringValue
    let urlForecastHourly = json["properties"]["forecastHourly"].stringValue
    let urlStations = json["properties"]["observationStations"].stringValue
    
    // 1. Importer le JSON des prévisions par jour (ex. https://api.weather.gov/gridpoints/LWX/96,70/forecast)
    dispatchGroup.enter()
    let taskForecast = URLSession.shared.dataTask(with: URL(string: urlForecast)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue du côté client lors de l'importation des prévisions par jour de la NOAA")
        //self.handleClientError(error)
        self.dispatchGroup.leave()
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print(error ?? "Erreur inconnue du côté serveur (code HTTP pas dans les 200) lors de l'importation des prévisions par jour de la NOAA")
          //self.handleServerError(response)
          self.dispatchGroup.leave()
          return
      }
      // Parser le JSON
      do {
        let json = try JSON(data: data)
        previsionsParJour = self.parseJSONForecast(json)
      } catch {
        print("Erreur de parsage JSON pour les prévisions par jour de la NOAA")
      }
      self.dispatchGroup.leave()
    }
    taskForecast.resume()
    
    // 2. Importer le JSON des prévisions par heure (ex. https://api.weather.gov/gridpoints/LWX/96,70/forecast/hourly)
    self.dispatchGroup.enter()
    let taskForecastHourly = URLSession.shared.dataTask(with: URL(string: urlForecastHourly)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue du côté client lors de l'importation des prévisions horaires de la NOAA")
        //self.handleClientError(error)
        self.dispatchGroup.leave()
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print(error ?? "Erreur inconnue du côté serveur (code HTTP pas dans les 200) lors de l'importation des prévisions horaires de la NOAA")
          //self.handleServerError(response)
          self.dispatchGroup.leave()
          return
      }
      // Parser le JSON
      do {
        let json = try JSON(data: data)
        previsionsParHeure = self.parseJSONHourlyForecast(json)
      } catch {
        print("Erreur de parsage JSON pour les prévisions horaires de la NOAA")
      }
      self.dispatchGroup.leave()
    }
    taskForecastHourly.resume()
    
    // 3. importer le JSON des stations, qui servira lui-même à importer le JSON des dernières observations
    // (ex. https://api.weather.gov/gridpoints/BTV/88,56/stations suivi de https://api.weather.gov/stations/KBTV/observations/latest)
    dispatchGroup.enter()
    let taskStations = URLSession.shared.dataTask(with: URL(string: urlStations)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue du côté client lors de l'importation des stations de la NOAA")
        //self.handleClientError(error)
        self.dispatchGroup.leave()
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print(error ?? "Erreur inconnue du côté serveur (code HTTP pas dans les 200) lors de l'importation des stations de la NOAA")
          //self.handleServerError(response)
          self.dispatchGroup.leave()
          return
      }
      // Parser le JSON
      do {
        let json = try JSON(data: data)
        let urlObservations = self.parseJSONStations(json)
        
        // 4. À l'intérieur du completion handler de la tâche des stations, faire la tâche des observations
        self.dispatchGroup.enter()
        let taskObservations = URLSession.shared.dataTask(with: URL(string: urlObservations)!) { data, response, error in
          guard let data = data, error == nil else {
            print(error ?? "Erreur inconnue du côté client lors de l'importation des observations de la NOAA")
            //self.handleClientError(error)
            self.dispatchGroup.leave()
            return
          }
          guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
              print(error ?? "Erreur inconnue du côté serveur (code HTTP pas dans les 200) lors de l'importation des observations de la NOAA")
              //self.handleServerError(response)
              self.dispatchGroup.leave()
              return
          }
          // Parser le JSON
          do {
            let json = try JSON(data: data)
            conditionsActuelles = self.parseJSONObservations(json)
          } catch {
            print("Erreur de parsage JSON pour les observations de la NOAA")
          }
          self.dispatchGroup.leave()
        }
        taskObservations.resume()
      } catch {
        print("Erreur de parsage JSON pour les stations de la NOAA")
      }
      self.dispatchGroup.leave()
    }
    taskStations.resume()

    // Appeler le completionHandler une fois que toutes les tâches ont été complétées
    self.dispatchGroup.notify(queue: .main) {
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
      previsionEnEdition.nuit = !objetPrevision["isDaytime"].boolValue
      previsionEnEdition.heureDebut = Calendar.current.date(bySettingHour: (previsionEnEdition.nuit ?? false) ? 18 : 6, minute: 0, second: 0, of: heurePrevision)
      previsionEnEdition.heureEmission = heureEmission

      let heureFinPrevision = dateFormatter.date(from: objetPrevision["endTime"].stringValue)
      previsionEnEdition.heureFin = heureFinPrevision
      previsionEnEdition.chainePeriode = objetPrevision["name"].stringValue
      if let temperatureFahrenheit = objetPrevision["temperature"].double {
        previsionEnEdition.temperature = Measurement(value: temperatureFahrenheit, unit: UnitTemperature.fahrenheit)
      }
      
      var chaineVitesseVent = objetPrevision["windSpeed"].stringValue
      chaineVitesseVent = chaineVitesseVent.replacingOccurrences(of: " mph", with: "")
      let composants = chaineVitesseVent.components(separatedBy: " to ")
      if composants.count >= 1, let vitesseVent = Double(composants[0]) {
        previsionEnEdition.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.milesPerHour)
      }
      if composants.count >= 2, let vitesseVentMax = Double(composants[1]) {
        previsionEnEdition.vitesseVentMax = Measurement(value: vitesseVentMax, unit: UnitSpeed.milesPerHour)
      }
      previsionEnEdition.directionVent = PointCardinal(rawValue: objetPrevision["windDirection"].stringValue)
      
      let chaineCondition = objetPrevision["shortForecast"].stringValue
      previsionEnEdition.chaineCondition = chaineCondition
      previsionEnEdition.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
      if previsionEnEdition.condition == nil, chaineCondition != "" {
        print("Incapable de parser la condition NOAA \(chaineCondition)")
      }
      previsionEnEdition.detailsCondition = objetPrevision["detailedForecast"].stringValue
      
      // Ajouter la prévision
      previsionsParJour[previsionEnEdition.heureDebut] = previsionEnEdition
    }
    
    return previsionsParJour
  }
  
  func parseJSONHourlyForecast(_ json: JSON) -> [Date : Prevision]{
    var previsionsParHeure = [Date : Prevision]()
    
    let heureEmission = dateFormatter.date(from: json["properties"]["updated"].stringValue)
    
    let periods = json["properties"]["periods"].arrayValue
    for objetPrevision in periods {
      // Obtenir l'heure de la prévision
//      print(objetPrevision["startTime"].stringValue) // pour déboguer les problèmes de cache
      guard let heurePrevision = dateFormatter.date(from: objetPrevision["startTime"].stringValue) else {
        continue
      }
//      print(heurePrevision)
      
      // Créer la prévision
      var previsionEnEdition = Prevision()
      previsionEnEdition.type = .horaire
      previsionEnEdition.source = .NOAA
      previsionEnEdition.nuit = !objetPrevision["isDaytime"].boolValue
      previsionEnEdition.heureEmission = heureEmission
      previsionEnEdition.heureDebut = heurePrevision
      
      let heureFinPrevision = dateFormatter.date(from: objetPrevision["endTime"].stringValue)
      previsionEnEdition.heureFin = heureFinPrevision
      previsionEnEdition.chainePeriode = objetPrevision["name"].stringValue
      if let temperatureFahrenheit = objetPrevision["temperature"].double {
        previsionEnEdition.temperature = Measurement(value: temperatureFahrenheit, unit: UnitTemperature.fahrenheit)
      }
      
      var chaineVitesseVent = objetPrevision["windSpeed"].stringValue
      chaineVitesseVent = chaineVitesseVent.replacingOccurrences(of: " mph", with: "")
      let composants = chaineVitesseVent.components(separatedBy: " to ")
      if composants.count >= 1, let vitesseVent = Double(composants[0]) {
        previsionEnEdition.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.milesPerHour)
      }
      if composants.count >= 2, let vitesseVentMax = Double(composants[1]) {
        previsionEnEdition.vitesseVentMax = Measurement(value: vitesseVentMax, unit: UnitSpeed.milesPerHour)
      }
      previsionEnEdition.directionVent = PointCardinal(rawValue: objetPrevision["windDirection"].stringValue)
      
      let chaineCondition = objetPrevision["shortForecast"].stringValue
      previsionEnEdition.chaineCondition = chaineCondition
      previsionEnEdition.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
      if previsionEnEdition.condition == nil, chaineCondition != "" {
        print("Incapable de parser la condition NOAA \(chaineCondition)")
      }
      previsionEnEdition.detailsCondition = objetPrevision["detailedForecast"].stringValue
      
      // Ajouter la prévision
      previsionsParHeure[previsionEnEdition.heureDebut] = previsionEnEdition
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
//    conditionsActuelles.lieu = 
    
    let objetPrevision = json["properties"]

    let heureObservation = dateFormatter.date(from: objetPrevision["timestamp"].stringValue)
    conditionsActuelles.heureDebut = heureObservation
    conditionsActuelles.heureEmission = heureObservation
    
    let chaineCondition = objetPrevision["textDescription"].stringValue
    conditionsActuelles.chaineCondition = chaineCondition
    conditionsActuelles.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
    if conditionsActuelles.condition == nil, chaineCondition != "" {
      print("Incapable de parser la condition NOAA \(chaineCondition)")
    }
    
    if let temperatureCelsius = objetPrevision["temperature"]["value"].double {
      conditionsActuelles.temperature = Measurement(value: temperatureCelsius, unit: UnitTemperature.celsius) // déjà en Celsius
    }
    if let pointDeRosee = objetPrevision["dewpoint"]["value"].double {
      conditionsActuelles.pointDeRosee = Measurement(value: pointDeRosee, unit: UnitTemperature.celsius)  // déjà en Celsius
    }
    conditionsActuelles.directionVentDegres = objetPrevision["windDirection"]["value"].doubleValue
    if let vitesseVent = objetPrevision["windSpeed"]["value"].double {
      conditionsActuelles.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.kilometersPerHour)  // déjà en km/h
    }
    if let vitesseRafales = objetPrevision["windGust"]["value"].double {
      conditionsActuelles.vitesseRafales = Measurement(value: vitesseRafales, unit: UnitSpeed.kilometersPerHour)  // déjà en km/h
    }
    if let pression = objetPrevision["seaLevelPressure"]["value"].double {
      conditionsActuelles.pression = Measurement(value: pression, unit: UnitPressure.newtonsPerMetersSquared) // valeur en Pa (égal à N/m^2)
    }
    if let visibilite = objetPrevision["visibility"]["value"].double {
      conditionsActuelles.visibilite = Measurement(value: visibilite, unit: UnitLength.meters) // valeur en m
    }
    conditionsActuelles.humidite = objetPrevision["relativeHumidity"]["value"].doubleValue
    if let humidex = objetPrevision["heatIndex"]["value"].double {
      conditionsActuelles.humidex = Measurement(value: humidex, unit: UnitTemperature.celsius)  // déjà en Celsius
    }
    if let refroidissementEolien = objetPrevision["windChill"]["value"].double {
      conditionsActuelles.refroidissementEolien = Measurement(value: refroidissementEolien, unit: UnitTemperature.celsius)  // déjà en Celsius
    }
    
    return conditionsActuelles
  }
}

// Mettre une condition en minuscules et standardiser certaines conditions
private func nettoyerChaineCondition(_ chaine: String) -> String {
  var chaineNettoyee = chaine.lowercased()
  // Si la condition inclut une évolution dans le futur avec "then", considérer seulement ce qui vient avant
  if chaineNettoyee.contains(" then ") {
    chaineNettoyee = chaineNettoyee.components(separatedBy: " then ")[0]
  }
  // Assimiler les "slight chance" et "likely" à simplement "chance"
  chaineNettoyee = chaineNettoyee.replacingOccurrences(of: "slight chance", with: "chance")
  if chaineNettoyee.contains("likely") {
    chaineNettoyee = "chance " + chaineNettoyee.replacingOccurrences(of: " likely", with: "")
  }
  // Assimiler les "scattered" à "isolated"
  chaineNettoyee = chaineNettoyee.replacingOccurrences(of: "scattered", with: "isolated")
  // Assimiler les "areas of" à "areas"
  chaineNettoyee = chaineNettoyee.replacingOccurrences(of: "areas of", with: "areas")
  // Identifier la sorte de sleet (aux États-Unis, ça signifie ice pellets)
  if chaineNettoyee.contains("sleet") {
    chaineNettoyee = chaineNettoyee + " (ice pellets)"
  }
  return chaineNettoyee
}
