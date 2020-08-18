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
  var nuit: Bool?
  var heureLeverDuSoleil: Date?
  var heureCoucherDuSoleil: Date?
  
  var condition: Condition? // ex : nuageux, ensoleillé, pluie
  var chaineCondition: String?
  var detailsCondition: String? // texte pour donner plus de détails

  // En général, seule l'une de ces trois variables est requise.
  // Dans de rares cas (tendance inverse de la température), on a besoin de Min et Max
  var temperature: Measurement<UnitTemperature>? // °C
  var temperatureMax: Measurement<UnitTemperature>?
  var temperatureMin: Measurement<UnitTemperature>?
  
  var probPrecipitation: Double? // %
  var quantitePrecipitation: Double? // mm
  
  var directionVent: PointCardinal?
  var directionVentDegres: Double? // degrés
  var vitesseVent: Measurement<UnitSpeed>? // km/h
  var vitesseVentMax: Measurement<UnitSpeed>? // km/h, pour les cas comme "10 à 15 km/h"
  var vitesseRafales: Measurement<UnitSpeed>? // km/h
  
  var pression: Measurement<UnitPressure>? // kPa
  var tendancePression: TendancePression? // à la hausse, à la baisse, stable
  var changementPression: Measurement<UnitPressure>?
  
  var humidite: Double? // %
  var pointDeRosee: Measurement<UnitTemperature>? // °C
  var visibilite: Measurement<UnitLength>? // km
  var indiceUV: Double?
  
  var temperatureRessentie: Measurement<UnitTemperature>? // utilisé quand on ignore si c'est l'humidex, le refroidissement éolien, etc.
  var humidex: Measurement<UnitTemperature>?
  var refroidissementEolien: Measurement<UnitTemperature>?
  
  var couvertureNuageuse: Double? // %
  
  var certitude: Int?
  
  var dateFormatterPrevisionHoraire = DateFormatter()
  
  //MARK: Initialisation
  
  init() {
    // Date Formatter
    dateFormatterPrevisionHoraire.dateStyle = .none
    dateFormatterPrevisionHoraire.timeStyle = .short
    dateFormatterPrevisionHoraire.locale = Locale.current // à faire : s'assurer que l'heure affichée corresponde au fuseau horaire du lieu, pas de l'utilisateur
  }
  
  //MARK: Getters
  
  func donneTemperature() -> Measurement<UnitTemperature> {
    return self.temperature ?? (self.estNuit() ? self.temperatureMin : self.temperatureMax)!
  }
  
  func donneTemperatureRessentie() -> Measurement<UnitTemperature>? {
    return self.temperatureRessentie ?? self.refroidissementEolien ?? self.humidex ?? nil
  }
  
  func donneHeure() -> Date {
    return self.heureDebut
  }
  func donneChaineHeure() -> String {
    return dateFormatterPrevisionHoraire.string(from: self.heureDebut)
  }
  
  func donneChaineHeureEmission() -> String? {
    if let heureEmission = self.heureEmission {
      return dateFormatterPrevisionHoraire.string(from: heureEmission)
    }
    return nil
  }
  
  func donneChainePeriode() -> String? {
    if self.type == .horaire {
      return self.donneChaineHeure()
    } else {
      return self.chainePeriode
    }
  }
  
  func donneVitesseVent() -> Measurement<UnitSpeed>? {
    return self.vitesseVent
  }
  
  func donneVitesseRafales() -> Measurement<UnitSpeed>? {
    return self.vitesseRafales
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
  
  func donneIndiceUV() -> Int? {
    if let indiceUV = self.indiceUV {
      return Int(indiceUV.rounded())
    }
    return nil
  }
  
  func donneProbPrecipitationArrondie() -> Int? {
    if let probPrecipitation = self.probPrecipitation?.rounded() {
      return Int(probPrecipitation)
    }
    return nil
  }
  
  
  // À raffiner selon les heures, et selon les autres sources de données, mais ceci devrait suffire pour Environnement Canada
  func estNuit() -> Bool {
    
    if let nuit = self.nuit {
      return nuit
    }
    
    guard let type = self.type else {
      return false
    }
    switch type {
      
    case .actuel:
      let heureCourante = Date()
      if let heureLeverDuSoleil = self.heureLeverDuSoleil,
        let heureCoucherDuSoleil = self.heureCoucherDuSoleil {
        if heureCourante < heureLeverDuSoleil || heureCourante > heureCoucherDuSoleil {
          return true
        }
        return false
      }
      
    case .quotidien:
      if chainePeriode?.contains("night") ?? false {
        return true
      }
      return false
      
    case .horaire:
      if let heureLeverDuSoleil = self.heureLeverDuSoleil,
        let heureCoucherDuSoleil = self.heureCoucherDuSoleil {
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
    //return "Prévision pour \(lieu ?? "[erreur lieu]") à \(heureDebut ?? Date()) : \(temperature ?? temperatureMax ?? temperatureMin ?? -999) °C. "
    return "\(source.rawValue), \(lieu ?? "[erreur lieu]"), \(donneChaineHeure()), \(donneTemperature().value)"
  }
}
