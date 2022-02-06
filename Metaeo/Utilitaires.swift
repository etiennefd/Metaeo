//
//  Utilitaires.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-08.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit
import CoreLocation

//MARK: Enums

enum TypePrevision {
  case actuel, quotidien, horaire
}

enum PointCardinal: String {
  case N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
  
  var localizedString: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
}

enum TendancePression: String {
  case falling, rising, steady

  var fleche: String {
    switch self {
    case .falling: return "↓"
    case .rising: return "↑"
    case .steady: return "→"
    }
  }
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

// MARK: Extensions

extension Double {
  func round(to places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}

// Extension pour le reverse geocoding de CLLocation
// source : https://stackoverflow.com/questions/44031257/find-city-name-and-country-from-latitude-and-longitude-in-swift
extension CLLocation {
  func obtenirLieu(completion: @escaping (_ lieu: CLPlacemark?, _ error: Error?) -> ()) {
    CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
  }
}

// MARK: aide au débogage

// Utile pour visualiser les prévisions d'un dict, car ça ne marche pas bien avec le débogueur
func printPrevisionsParPeriode(_ previsionsParPeriode: [Date : Prevision]) {
  for (date, prevision) in previsionsParPeriode {
    print("\(date) : \(prevision.debugDescription)")
  }
}

extension UIUserInterfaceStyle {
  var chaineModeSombre: String {
    switch self {
    case .unspecified:
      return NSLocalizedString("Auto", comment: "")
    case .dark:
      return NSLocalizedString("On", comment: "")
    case .light:
      return NSLocalizedString("Off", comment: "")
    default:
      return ""
    }
  }
}
