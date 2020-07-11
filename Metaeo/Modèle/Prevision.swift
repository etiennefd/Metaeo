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
  
  var type: TypePrevision!
  
  var lieu: String! // ex : Montréal
  var source: SourcePrevision! // ex : yr.no, Environnement Canada

  var heureEmission: Date? // moment où la prévision a été émise par la source
  var chainePeriode: String? // ex : Vendredi
  var heureDebut: Date! // doit toujours être utilisé
  var heureFin: Date? // pas utilisé pour l'instant
  
  var condition: Condition? // ex : nuageux, ensoleillé, pluie
  var detailsCondition: String? // texte pour donner plus de détails

  // En général, seule l'une de ces trois variables est requise.
  // Dans de rares cas (tendance inverse de la température), on a besoin de Min et Max
  var temperature: Double? // °C
  var temperatureMax: Double?
  var temperatureMin: Double?
  
  var probPrecipitation: Double? // %
  var quantitePrecipitation: Double? // mm
  
  var directionVent: PointCardinal?
  var directionVentDegres: Double? // degrés
  var vitesseVent: Double? // km/h
  var vitesseRafales: Double? // km/h
  
  var pression: Double? // kPa
  var tendancePression: TendancePression? // à la hausse, à la baisse, stable
  var changementPression: Double?
  
  var humidite: Double? // %
  var pointDeRosee: Double? // °C
  var visibilite: Double? // km
  var indiceUV: Double?
  
  var humidex: Int?
  var refroidissementEolien: Double?
  
  var certitude: Int?
  
  //MARK: Initialisation
  
//  init(lieu: String, heureDebut: Date, heureFin: Date, temperatureMax: Double, condition: String, source: String) {
//    self.lieu = lieu
//    self.heureDebut = heureDebut
//    self.heureFin = heureFin
//    self.temperatureMax = temperatureMax
//    self.condition = Condition(rawValue: condition)
//    //    self.icone = UIImage
//    self.source = source
//  }
  
  init() {
    
  }
  
  //MARK: Utilitaires
  
  // À faire : considérer les fahrenheit
  func donneTemperature() -> Double {
    return self.temperature ?? (self.estNuit() ? self.temperatureMin : self.temperatureMax) ?? 99.9
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
  
  func donneDirectionVent() -> PointCardinal? {
    if let directionVent = self.directionVent {
      return directionVent
    }
    if let directionVentDegres = self.directionVentDegres {
      return degresVersPointCardinal(directionVentDegres)
    }
    return nil
  }
  
  
  
  // À raffiner selon les heures, et selon les autres sources de données, mais ceci devrait suffire pour Environnement Canada
  func estNuit() -> Bool {
    if self.type == .jour {
      if chainePeriode?.contains("night") ?? false {
        return true
      }
      return false
    } else if self.type == .horaire {
      if let heureLeverDuSoleil = ImportateurPrevisions.global.donneesEnAffichage.heureLeverDuSoleil,
        let heureCoucherDuSoleil = ImportateurPrevisions.global.donneesEnAffichage.heureCoucherDuSoleil {
        // Avant le lever du jour actuel? C'est la nuit
        if self.heureDebut < heureLeverDuSoleil {
          return true
        }
        // Après le lever du jour actuel mais avant le coucher? C'est le jour
        if self.heureDebut < heureCoucherDuSoleil {
          return false
        }
        // Ajouter un jour aux heures de coucher et lever pour obtenir une estimation des lever/coucher du jour suivant
        var composantDateDecalage = DateComponents()
        composantDateDecalage.day = 1
        guard let heureProchainLeverDuSoleil = Calendar.current.date(byAdding: composantDateDecalage, to: heureLeverDuSoleil),
          let heureProchainCoucherDuSoleil = Calendar.current.date(byAdding: composantDateDecalage, to: heureCoucherDuSoleil) else {
            return false
        }
        // Après le coucher du jour actuel mais avant le lever du jour suivant? C'est la nuit
        if self.heureDebut < heureProchainLeverDuSoleil {
          return true
        }
        // Après le deuxième lever mais avant le deuxième coucher
        if self.heureDebut < heureProchainCoucherDuSoleil {
          return false
        }
        // Après le deuxième coucher
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
