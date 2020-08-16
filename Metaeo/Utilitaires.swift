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
  case environnementCanada = "Meteorological Service of Canada"
  case yrNo = "MET Norway"
  case NOAA = "National Weather Service"
  case openWeatherMap = "OpenWeatherMap"
  //case
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

//MARK: Enums des unités

//enum UniteTemperature: String {
//  case celsius = "°C"
//  case fahrenheit = "°F"
//  case kelvin = "K"
//}

//enum UniteDistance: String {
//  case km = "km"
//  case mile = "mi"
//}

//enum UniteVitesse: String {
//  case kmParHeure = "km/h"
//  case mileParHeure = "mph"
//  case metresParSeconde = "m/s"
//  case noeuds = "kn"
//  case beaufort = "Beaufort"
//  case piedParSeconde = "ft/s"
//}

//enum UnitePression: String {
//  case kilopascal = "kPa"
//  case hectopascal = "hPa"
//  case millibar = "mb"
//  case millimetreMercure = "mmHg"
//  case pouceMercure = "inHg"
//}

//MARK: Conversion d'unités

//func celsiusVersFahrenheit(_ celsius: Double) -> Double {
//  return celsius * 1.8 + 32
//}
//
//func fahrenheitVersCelsius(_ fahrenheit: Double) -> Double {
//  return (fahrenheit - 32) / 1.8
//}
//
//func celsiusVersKelvin(_ celsius: Double) -> Double {
//  return celsius + 273.15
//}
//
//func kelvinVersCelsius(_ kelvin: Double) -> Double {
//  return kelvin - 273.15
//}

//func kmVersMi(_ km: Double) -> Double {
//  return km * 0.621371
//}
//
//func miVersKm(_ mi: Double) -> Double {
//  return mi * 1.60934
//}
//
//func kmhVersMph(_ kmh: Double) -> Double {
//  return kmh * 0.621371
//}
//
//func mphVersKmh(_ mph: Double) -> Double {
//  return mph * 1.60934
//}
//
//func kmhVersMs(_ kmh: Double) -> Double {
//  return kmh * 0.277778
//}
//
//func msVersKmh(_ ms: Double) -> Double {
//  return ms * 3.6
//}
//
//func kmhVersNoeuds(_ kmh: Double) -> Double {
//  return kmh * 0.539957
//}
//
//func noeudsVersKmh(_ noeuds: Double) -> Double {
//  return noeuds * 1.852
//}
//
//func kmhVersFts(_ kmh: Double) -> Double {
//  return kmh * 0.911344
//}
//
//func ftsVersKmh(_ fts: Double) -> Double {
//  return fts * 1.09728
//}

func kmhVersBeaufort(_ kmh: Double) -> Double {
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
