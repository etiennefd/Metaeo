//
//  ParseurJSONYrNo.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-04.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ParseurJSONYrNo: NSObject {
  
  var conditionsActuelles: Prevision? // pas utilisé pour yr.no
  var previsionsParJour: [Date : Prevision]!
  var previsionsParHeure: [Date : Prevision]!
  
  func parseJSON(_ json: JSON) {
    self.previsionsParHeure = [Date : Prevision]()
    self.previsionsParJour = [Date : Prevision]()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    let heureEmission = dateFormatter.date(from: json["properties"]["meta"]["updated_at"].stringValue)
    
    let timeseries = json["properties"]["timeseries"].arrayValue
    for objetPrevision in timeseries {
//      let previsionJourEnEdition = Prevision()
      guard let heure = dateFormatter.date(from: objetPrevision["time"].stringValue) else {
        continue
      }
      var previsionHoraireEnEdition = Prevision()
      previsionHoraireEnEdition.type = .horaire
      previsionHoraireEnEdition.source = .yrNo
      previsionHoraireEnEdition.heureDebut = heure
      previsionHoraireEnEdition.heureEmission = heureEmission
      
      let donneesInstantanees = objetPrevision["data"]["instant"]["details"]
      previsionHoraireEnEdition.pression = donneesInstantanees["air_pressure_at_sea_level"].doubleValue / 10
      previsionHoraireEnEdition.temperature = donneesInstantanees["air_temperature"].doubleValue
      previsionHoraireEnEdition.pointDeRosee = donneesInstantanees["dew_point_temperature"].doubleValue
      previsionHoraireEnEdition.humidite = donneesInstantanees["relative_humidity"].doubleValue
      previsionHoraireEnEdition.indiceUV = donneesInstantanees["ultraviolet_index_clear_sky"].doubleValue
      previsionHoraireEnEdition.directionVentDegres = donneesInstantanees["wind_from_direction"].doubleValue
      previsionHoraireEnEdition.vitesseVent = donneesInstantanees["wind_speed"].doubleValue
      
      let codeSymboleCondition = objetPrevision["data"]["next_1_hours"]["summary"]["symbol_code"].stringValue
      let composants = codeSymboleCondition.components(separatedBy: "_")
      previsionHoraireEnEdition.condition = Condition(rawValue: composants[0])
//      if composants.count > 1 {
//        previsionHoraireEnEdition.estNuit = composants[1] == "night" || composants[1] == "polartwilight"
//      }
      
      self.previsionsParHeure[heure] = previsionHoraireEnEdition
    }
  }
  
  // À ENLEVER
  // que faire avec les "polar_twilight"??
//  private func codeSymboleVersCondition(_ codeSymbole: String) -> Condition {
//    switch codeSymbole {
//    case "clearsky_day":
//      return .sunny
//    case "clearsky_night":
//      return .clear
//    case "cloudy":
//      return .cloudy
//    case "fair_day", "fair_night":
//      return .aFewClouds
//    case "fog":
//      return .fog
//    case "heavyrain":
//      return .heavyRain
//    case "heavyrainandthunder":
//      return .thunderstorm
//    case "heavyrainshowers":
//      return .heavyRainShower
//      case "heavyrainshowersandthunder":
//      return .thunder
//      case "heavysleet":
//      return .heavyRainAndSnow
//      case "heavysleetandthunder":
//      return .
//      case "heavysleetshowers":
//      return .
//      case "heavysleetshowersandthunder":
//      return .
//      case "heavysnow":
//      return .heavySnow
//      case "heavysnowandthunder":
//      return .thunder
//      case "heavysnowshowers":
//      return .snow
//      case "heavysnowshowersandthunder":
//      return .
//      case "lightrain":
//      return .lightRain
//      case "lightrainandthunder":
//      return .thunderstormWithLightRain
//      case "lightrainshowers":
//      return .lightRainShower
//      case "lightrainshowersandthunder":
//      return .thunderstormWithLightRain
//      case "lightsleet":
//      return .lightRainAndSnow
//      case "lightsleetandthunder":
//      return .
//      case "lightsleetshowers":
//      return .li
//      case "lightsnow":
//      return .lightSnow
//    case "lightsnowandthunder":
//      return .
//      case "lightsnowshowers":
//      return .
//      case "lightssleetshowersandthunder":
//      return .thunder
//    case "lightssnowshowersandthunder":
//      return .
//      case "partlycloudy":
//      return .partlyCloudy
//    case "rain":
//      return .rain
//    case "rainandthunder":
//      return .thunderstormWithRain
//    case "rainshowers":
//      return .rainShower
//    case "rainshowersandthunder":
//      return .
//      case "sleet":
//      return .rainAndSnow
//    case "sleetandthunder":
//      return .
//      case "sleetshowers":
//      return .
//      case "sleetshowersandthunder":
//      return .
//      case "snow":
//      return .snow
//      case "snowandthunder":
//      return .thunderstormWithSnow
//      case "snowshowers":
//      return .flurries
//      case "snowshowersandthunder":
//      return .aFewFlurriesOrThundershowers
//    default:
//      <#code#>
//    }
//  }
}

