//
//  Utilitaires.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-08.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

//MARK: Enums

enum TypePrevision {
  case actuel, quotidien, horaire
}

enum PointCardinal: String {
  case N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
}

enum TendancePression: String {
  case falling, rising, steady
}

enum FormatDonnees {
  case xml, json
}

enum SourcePrevision: String {
    // Ne pas oublier de tout mettre dans le fichier Localizable.strings
  case environnementCanada = "Meteorological Service of Canada"
  case yrNo = "MET Norway"
  case NOAA = "National Weather Service"
  case openWeatherMap = "OpenWeatherMap"
  //case
  
  var localizedString: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
}

/*
 Donne la chaine localisée d'une condition, avec un peu de traitement pour certaines conditions complexes (de la NOAA)
 */
func localiseChaineCondition(_ condition: String) -> String {
  if Condition(rawValue: condition) != nil {
    return NSLocalizedString(condition, comment: "")
  }
  if condition.contains(" then ") {
    let composants = condition.components(separatedBy: " then ")
    if let premier = composants.first, let dernier = composants.last {
      return localiseChaineCondition(premier) + NSLocalizedString(" then ", comment: "") + localiseChaineCondition(dernier).lowercased()
    }
  }
  if condition.hasPrefix("slight ") {
    return NSLocalizedString("slight ", comment: "") + localiseChaineCondition(String(condition.dropFirst("slight ".count))).lowercased()
  }
  return NSLocalizedString(condition, comment: "")
}

func formatPourSource(_ source: SourcePrevision) -> FormatDonnees {
  switch source {
  case .environnementCanada:
    return .xml
  case .yrNo,
       .NOAA,
       .openWeatherMap:
    return .json
  }
}

//MARK: Unités de mesure en extra

extension UnitSpeed {
  static let feetPerSecond = UnitSpeed(symbol: "ft/s", converter: UnitConverterLinear(coefficient: 0.3048))
  
  static let beaufort = UnitSpeed(symbol: "Beaufort", converter: UnitConverterBeaufort())
  
  class UnitConverterBeaufort: UnitConverter {
    override func baseUnitValue(fromValue value: Double) -> Double {
      return 0.836 * pow(value, 1.5) // ne devrait jamais être utilisé, mais défini au cas où
    }
    
    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
      let kmh = baseUnitValue * 3.6 // la base est en m/s mais mon échelle est en km/h
      switch floor(kmh) {
      case 0:
        return 0
      case 1...5:
        return 1
      case 6...11:
        return 2
      case 12...19:
        return 3
      case 20...28:
        return 4
      case 29...38:
        return 5
      case 39...49:
        return 6
      case 50...61:
        return 7
      case 62...74:
        return 8
      case 75...88:
        return 9
      case 89...102:
        return 10
      case 103...117:
        return 11
      case 118...:
        return 12
      default:
        return 0
      }
    }
  }
}

extension UnitPressure {
  static let atmosphere = UnitPressure(symbol: "atm", converter: UnitConverterLinear(coefficient: 101325))
}

func degresVersPointCardinal(_ degres: Double) -> PointCardinal? {
  switch degres {
  case 0..<11.25, 348.75..<360:
    return .N
  case 11.25..<33.75:
    return .NNE
  case 33.75..<56.25:
    return .NE
  case 56.25..<78.75:
    return .ENE
  case 78.75..<101.25:
    return .E
  case 101.25..<123.75:
    return .ESE
  case 123.75..<146.25:
    return .SE
  case 146.25..<168.75:
    return .SSE
  case 168.75..<191.25:
    return .S
  case 191.25..<213.75:
    return .SSW
  case 213.75..<236.25:
    return .SW
  case 236.25..<258.75:
    return .WSW
  case 258.75..<281.25:
    return .W
  case 281.25..<303.75:
    return .WNW
  case 303.75..<326.25:
    return .NW
  case 326.25..<348.75:
    return .NNW
  default:
    return nil
  }
}

// MARK: aide au débogage

// Utile pour visualiser les prévisions d'un dict, car ça ne marche pas bien avec le débogueur
func printPrevisionsParPeriode(_ previsionsParPeriode: [Date : Prevision]) {
  for (date, prevision) in previsionsParPeriode {
    print("\(date) : \(prevision.debugDescription)")
  }
}
