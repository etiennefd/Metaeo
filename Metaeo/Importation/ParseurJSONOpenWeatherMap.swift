//
//  ParseurJSONOpenWeatherMap.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-23.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ParseurJSONOpenWeatherMap: ParseurJSON {
  
  func parseJSON(_ json: JSON, completionHandler: @escaping (Prevision?, [Date : Prevision]?, [Date : Prevision]?) -> Void) {
    var conditionsActuelles = Prevision()
    var previsionsParHeure = [Date : Prevision]()
    var previsionsParJour = [Date : Prevision]()
    
    // Conditions actuelles
    
    let objetCurrent = json["current"]
    conditionsActuelles.type = .actuel
    conditionsActuelles.source = .openWeatherMap
    conditionsActuelles.heureEmission = Date()
    conditionsActuelles.heureDebut = Date(timeIntervalSince1970: objetCurrent["dt"].doubleValue)
    let heureLeverDuSoleil = Date(timeIntervalSince1970: objetCurrent["sunrise"].doubleValue)
    let heureCoucherDuSoleil = Date(timeIntervalSince1970: objetCurrent["sunset"].doubleValue)
    conditionsActuelles.heureLeverDuSoleil = heureLeverDuSoleil
    conditionsActuelles.heureCoucherDuSoleil = heureCoucherDuSoleil
    if let temperature = objetCurrent["temp"].double {
      conditionsActuelles.temperature = Measurement(value: temperature, unit: UnitTemperature.celsius)
    }
    if let temperatureRessentie = objetCurrent["feels_like"].double {
      conditionsActuelles.temperatureRessentie = Measurement(value: temperatureRessentie, unit: UnitTemperature.celsius)
    }
    if let pression = objetCurrent["pressure"].double {
      conditionsActuelles.pression = Measurement(value: pression, unit: UnitPressure.hectopascals) // la valeur est en hPa
    }
    conditionsActuelles.humidite = objetCurrent["humidity"].double
    if let pointDeRosee = objetCurrent["dew_point"].double {
      conditionsActuelles.pointDeRosee = Measurement(value: pointDeRosee, unit: UnitTemperature.celsius)
    }
    conditionsActuelles.couvertureNuageuse = objetCurrent["clouds"].double
    conditionsActuelles.indiceUV = objetCurrent["uvi"].double
    if let visibilite = objetCurrent["visibility"].double {
      conditionsActuelles.visibilite = Measurement(value: visibilite, unit: UnitLength.meters) // la valeur est en m
    }
    if let vitesseVent = objetCurrent["wind_speed"].double {
      conditionsActuelles.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.kilometersPerHour)
    }
    if let vitesseRafales = objetCurrent["wind_gust"].double {
      conditionsActuelles.vitesseRafales = Measurement(value: vitesseRafales, unit: UnitSpeed.kilometersPerHour)
    }
    conditionsActuelles.directionVentDegres = objetCurrent["wind_deg"].double
    if let objetCondition = objetCurrent["weather"].arrayValue.first {
      let chaineCondition = objetCondition["description"].stringValue
      conditionsActuelles.chaineCondition = chaineCondition
      conditionsActuelles.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
      if conditionsActuelles.condition == nil {
        print("Incapable de parser la condition OWM \(chaineCondition)")
      }
    }
    
    // Prévisions horaires
    
    let hourlyForecasts = json["hourly"].arrayValue
    for objetHourly in hourlyForecasts {
      
      // Créer la prévision horaire
      var previsionHoraire = Prevision()
      
      previsionHoraire.type = .horaire
      previsionHoraire.source = .openWeatherMap
      previsionHoraire.heureEmission = Date()
      let heurePrevision = Date(timeIntervalSince1970: objetHourly["dt"].doubleValue)
      previsionHoraire.heureDebut = heurePrevision
      previsionHoraire.heureLeverDuSoleil = heureLeverDuSoleil
      previsionHoraire.heureCoucherDuSoleil = heureCoucherDuSoleil
      if let temperature = objetCurrent["temp"].double {
        previsionHoraire.temperature = Measurement(value: temperature, unit: UnitTemperature.celsius)
      }
      if let temperatureRessentie = objetHourly["feels_like"].double {
        previsionHoraire.temperatureRessentie = Measurement(value: temperatureRessentie, unit: UnitTemperature.celsius)
      }
      if let pression = objetHourly["pressure"].double {
        previsionHoraire.pression = Measurement(value: pression, unit: UnitPressure.hectopascals) // la valeur est en hPa
      }
      previsionHoraire.humidite = objetHourly["humidity"].double
      if let pointDeRosee = objetHourly["dew_point"].double {
        previsionHoraire.pointDeRosee = Measurement(value: pointDeRosee, unit: UnitTemperature.celsius)
      }
      previsionHoraire.couvertureNuageuse = objetHourly["clouds"].double
      if let visibilite = objetCurrent["visibility"].double {
        previsionHoraire.visibilite = Measurement(value: visibilite, unit: UnitLength.meters) // la valeur est en m
      }
      if let vitesseVent = objetCurrent["wind_speed"].double {
        previsionHoraire.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.kilometersPerHour)
      }
      if let vitesseRafales = objetCurrent["wind_gust"].double {
        previsionHoraire.vitesseRafales = Measurement(value: vitesseRafales, unit: UnitSpeed.kilometersPerHour)
      }
      previsionHoraire.directionVentDegres = objetHourly["wind_deg"].double
      if let objetCondition = objetHourly["weather"].arrayValue.first {
        let chaineCondition = objetCondition["description"].stringValue
        previsionHoraire.chaineCondition = chaineCondition
        previsionHoraire.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
        if previsionHoraire.condition == nil {
          print("Incapable de parser la condition OWM \(chaineCondition)")
        }
      }
      previsionHoraire.probPrecipitation = objetHourly["pop"].double
      let quantitePluie = objetHourly["rain"]["1h"].doubleValue
      let quantiteNeige = objetHourly["snow"]["1h"].doubleValue
      previsionHoraire.quantitePrecipitation = max(quantitePluie, quantiteNeige) // on suppose qu'on ne peut pas avoir les deux en même temps
      
      // Ajouter la prévision horaire
      previsionsParHeure[heurePrevision] = previsionHoraire
    }
    
    // Prévisions par jour
    
    var calendrierLocal = Calendar.current
    //calendar.timeZone = timeZone du lieu de la prévision
    calendrierLocal.locale = Locale(identifier: "en_US")
    let joursDeLaSemaine = calendrierLocal.weekdaySymbols
    
    let dailyForecasts = json["daily"].arrayValue
    for objetDaily in dailyForecasts {
      
      // Créer les prévisions quotidiennes pour le jour et la nuit
      var previsionJour = Prevision()
      var previsionNuit = Prevision()
      
      previsionJour.type = .quotidien
      previsionNuit.type = .quotidien
      previsionJour.source = .openWeatherMap
      previsionNuit.source = .openWeatherMap
      previsionJour.nuit = false
      previsionNuit.nuit = true
      previsionJour.heureEmission = Date()
      previsionNuit.heureEmission = Date()
      let heureObjetPrevision = Date(timeIntervalSince1970: objetDaily["dt"].doubleValue)
      previsionJour.heureDebut = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: heureObjetPrevision)
      previsionNuit.heureDebut = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: heureObjetPrevision)
      let chaineJourDeLaSemaine = joursDeLaSemaine[calendrierLocal.component(.weekday, from: heureObjetPrevision) - 1]
      previsionJour.chainePeriode = chaineJourDeLaSemaine
      previsionNuit.chainePeriode = chaineJourDeLaSemaine + " night"
      let heureLeverDuSoleil = Date(timeIntervalSince1970: objetDaily["sunrise"].doubleValue)
      let heureCoucherDuSoleil = Date(timeIntervalSince1970: objetDaily["sunset"].doubleValue)
      previsionJour.heureLeverDuSoleil = heureLeverDuSoleil
      previsionNuit.heureLeverDuSoleil = heureLeverDuSoleil
      previsionJour.heureCoucherDuSoleil = heureCoucherDuSoleil
      previsionNuit.heureCoucherDuSoleil = heureCoucherDuSoleil
      if let temperatureMax = objetDaily["temp"]["max"].double { // peut être différent de ["temp"]["day"]
        previsionJour.temperature = Measurement(value: temperatureMax, unit: UnitTemperature.celsius)
      }
      if let temperatureMin = objetDaily["temp"]["min"].double { // peut être différent de ["temp"]["night"]
        previsionNuit.temperature = Measurement(value: temperatureMin, unit: UnitTemperature.celsius)
      }
      if let temperatureRessentieJour = objetDaily["feels_like"]["day"].double {
        previsionJour.temperatureRessentie = Measurement(value: temperatureRessentieJour, unit: UnitTemperature.celsius)
      }
      if let temperatureRessentieNuit = objetDaily["feels_like"]["night"].double {
        previsionNuit.temperatureRessentie = Measurement(value: temperatureRessentieNuit, unit: UnitTemperature.celsius)
      }
      if let pression = objetDaily["pressure"].double {
        previsionJour.pression = Measurement(value: pression, unit: UnitPressure.hectopascals) // la valeur est en hPa
        previsionNuit.pression = Measurement(value: pression, unit: UnitPressure.hectopascals)
      }
      previsionJour.humidite = objetDaily["humidity"].double
      previsionNuit.humidite = objetDaily["humidity"].double
      if let pointDeRosee = objetDaily["dew_point"].double {
        previsionJour.pointDeRosee = Measurement(value: pointDeRosee, unit: UnitTemperature.celsius)
        previsionNuit.pointDeRosee = Measurement(value: pointDeRosee, unit: UnitTemperature.celsius)
      }
      previsionJour.couvertureNuageuse = objetDaily["clouds"].double
      previsionNuit.couvertureNuageuse = objetDaily["clouds"].double
      previsionJour.indiceUV = objetDaily["uvi"].double
      previsionNuit.indiceUV = objetDaily["uvi"].double
      if let visibilite = objetCurrent["visibility"].double {
        previsionJour.visibilite = Measurement(value: visibilite, unit: UnitLength.meters) // la valeur est en m
        previsionNuit.visibilite = Measurement(value: visibilite, unit: UnitLength.meters) // la valeur est en m
      }
      if let vitesseVent = objetCurrent["wind_speed"].double {
        previsionJour.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.kilometersPerHour)
        previsionNuit.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.kilometersPerHour)
      }
      if let vitesseRafales = objetCurrent["wind_gust"].double {
        previsionJour.vitesseRafales = Measurement(value: vitesseRafales, unit: UnitSpeed.kilometersPerHour)
        previsionNuit.vitesseRafales = Measurement(value: vitesseRafales, unit: UnitSpeed.kilometersPerHour)
      }
      previsionJour.directionVentDegres = objetDaily["wind_deg"].double
      previsionNuit.directionVentDegres = objetDaily["wind_deg"].double
      if let objetCondition = objetDaily["weather"].arrayValue.first {
        let chaineCondition = objetCondition["description"].stringValue
        previsionJour.chaineCondition = chaineCondition
        previsionNuit.chaineCondition = chaineCondition
        previsionJour.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
        previsionNuit.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
        if previsionJour.condition == nil {
          print("Incapable de parser la condition OWM \(chaineCondition)")
        }
      }
      previsionJour.probPrecipitation = objetDaily["pop"].double
      previsionNuit.probPrecipitation = objetDaily["pop"].double
      
      // Ajouter les deux prévisions
      previsionsParJour[previsionJour.heureDebut] = previsionJour
      previsionsParJour[previsionNuit.heureDebut] = previsionNuit
    }
    
    completionHandler(conditionsActuelles, previsionsParJour, previsionsParHeure)
  }
}

// Identifier la sorte de sleet
private func nettoyerChaineCondition(_ chaine: String) -> String {
  var chaineNettoyee = chaine.lowercased()
  // Identifier la sorte de sleet (pour OWM, ça semble être ice pellets)
  if chaineNettoyee.contains("sleet") {
    chaineNettoyee = chaineNettoyee + " (ice pellets)"
  }
  return chaineNettoyee
}
