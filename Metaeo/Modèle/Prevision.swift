//
//  Prevision.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-08.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

struct Prevision: CustomDebugStringConvertible {
  
  //MARK: Propriétés
  
  var lieu: String! // ex : Montréal
  var source: String! // ex : yr.no, Environnement Canada

  var heureEmission: Date? // moment où la prévision a été émise par la source
  var chainePeriode: String? // ex : Vendredi
  var heureDebut: Date! // doit toujours être utilisé
  var heureFin: Date? // pas utilisé pour l'instant
  
  var condition: Condition? // ex : nuageux, ensoleillé, pluie
  var detailsCondition: String? // texte pour donner plus de détails

  // En général, seule l'une de ces trois variables est requise.
  // Dans de rares cas (tendance inverse de la température), on a besoin de Min et Max
  var temperature: Double?
  var temperatureMax: Double?
  var temperatureMin: Double?
  
  var probPrecipitation: Double?
  var quantitePrecipitation: Int?
  
  var directionVent: PointCardinal?
  var directionVentDegres: Int?
  var vitesseVent: Int?
  var vitesseRafales: Int?
  
  var pression: Double?
  var tendancePression: TendancePression? // à la hausse, à la baisse, stable
  var changementPression: Double?
  
  var humidite: Double?
  var pointDeRosee: Double?
  var visibilite: Double?
  var indiceUV: Int?
  
  var humidex: Int?
  var refroidissementEolien: Int?
  
  var certitude: Int?
  
  //MARK: Initialisation
  
  init(lieu: String, heureDebut: Date, heureFin: Date, temperatureMax: Double, condition: String, source: String) {
    self.lieu = lieu
    self.heureDebut = heureDebut
    self.heureFin = heureFin
    self.temperatureMax = temperatureMax
    self.condition = Condition(rawValue: condition)
    //    self.icone = UIImage
    self.source = source
  }
  
  init() {
    
  }
  
  //MARK: Utilitaires
  
  // À faire : considérer les fahrenheit
  func donneTemperature() -> Double {
    return self.temperature ?? self.temperatureMax ?? self.temperatureMin ?? 99.9
  }
  func donneTemperatureArrondie() -> Int {
    return Int(self.donneTemperature().rounded())
  }
  func chaineTemperature() -> String {
    return "\(self.donneTemperatureArrondie()) °C"
  }
  
  func donneHeure() -> Date {
    return self.heureDebut
  }
  
  func donneIcone() -> UIImage? {
    guard let condition = self.condition else {
      return UIImage(named: "na")
    }
    switch condition {
    case .sunny:
      return UIImage(named: "sunny")
    case .cloudy:
      return UIImage(named: "cloudy")
    case .lightRain:
      return UIImage(named: "light rain")
    case .mostlyCloudy:
      return self.estNuit() ? UIImage(named: "mostly cloudy night") : UIImage(named: "mostly cloudy")
    case .thunderstorm, .thunderstormWithLightRain:
      return UIImage(named: "thunderstorm")
    default:
      return UIImage(named: "na")
    }
  }
  
  // À raffiner selon les heures, et selon les autres sources de données, mais ceci devrait suffire pour Environnement Canada
  func estNuit() -> Bool {
    if chainePeriode?.contains("night") ?? false {
      return true
    }
    if let heureLeverDuSoleil = ImportateurPrevisions.global.heureLeverDuSoleil,
      let heureCoucherDuSoleil = ImportateurPrevisions.global.heureCoucherDuSoleil {
      if self.heureDebut.compare(heureLeverDuSoleil) == .orderedAscending
        || self.heureDebut.compare(heureCoucherDuSoleil) == .orderedDescending {
        return true
      }
    }
    return false
  }
  
  //MARK: Description

  var debugDescription: String {
    return "Prévision pour \(lieu ?? "[erreur lieu]") à \(heureDebut ?? Date()) : \(temperature ?? temperatureMax ?? temperatureMin ?? -999) °C. "
  }
}
