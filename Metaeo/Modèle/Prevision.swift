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
  var temperature: Double?
  var temperatureMax: Double?
  var temperatureMin: Double?
  
  var probPrecipitation: Double?
  var quantitePrecipitation: Int?
  
  var directionVent: PointCardinal?
  var directionVentDegres: Double?
  var vitesseVent: Double?
  var vitesseRafales: Double?
  
  var pression: Double?
  var tendancePression: TendancePression? // à la hausse, à la baisse, stable
  var changementPression: Double?
  
  var humidite: Double?
  var pointDeRosee: Double?
  var visibilite: Double?
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
      if var heureLeverDuSoleil = ImportateurPrevisions.global.donneesEnAffichage.heureLeverDuSoleil,
        var heureCoucherDuSoleil = ImportateurPrevisions.global.donneesEnAffichage.heureCoucherDuSoleil {
        // Le lever et le coucher sont ceux de la date d'émission de la prévision.
        // Pour savoir si la prévision est de nuit, il faut comparer avec le prochain lever/coucher.
        // Donc on ajoute 1 jour si l'émission des prévisions a été faite après le lever/coucher du jour même.
        var composantDateDecalage = DateComponents()
        composantDateDecalage.day = 1
        if let heureEmission = self.heureEmission, heureEmission > heureLeverDuSoleil /*émission après lever*/ {
          heureLeverDuSoleil = Calendar.current.date(byAdding: composantDateDecalage, to: heureLeverDuSoleil) ?? heureLeverDuSoleil
        }
        if let heureEmission = self.heureEmission, heureEmission > heureCoucherDuSoleil /*émission après coucher*/{
          heureCoucherDuSoleil = Calendar.current.date(byAdding: composantDateDecalage, to: heureCoucherDuSoleil) ?? heureCoucherDuSoleil
        }
        if self.heureDebut < heureLeverDuSoleil /*prévision avant lever*/
          || heureLeverDuSoleil < heureCoucherDuSoleil, self.heureDebut > heureCoucherDuSoleil /*prévision après coucher*/ {
          return true
        }
      }
    }
    return false
  }
  
  //MARK: Description

  var debugDescription: String {
    return "Prévision pour \(lieu ?? "[erreur lieu]") à \(heureDebut ?? Date()) : \(temperature ?? temperatureMax ?? temperatureMin ?? -999) °C. "
  }
}
