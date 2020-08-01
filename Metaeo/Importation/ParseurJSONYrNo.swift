//
//  ParseurJSONYrNo.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-04.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ParseurJSONYrNo: ParseurJSON {
  
  func parseJSON(_ json: JSON, completionHandler: @escaping (Prevision?, [Date : Prevision]?, [Date : Prevision]?) -> Void) {
    var previsionsParHeure = [Date : Prevision]()
    var previsionsParJour = [Date : Prevision]()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    let heureEmission = dateFormatter.date(from: json["properties"]["meta"]["updated_at"].stringValue)
    
    var previsionJourEnEdition: Prevision? = nil
    
    // Variables pour bien créer les conditions du jour actuel
    var aCreePrevisionDuJourMeme = false
    var doitAjusterSelonDeuxiemePeriodeDe6h = false
    var intHeurePrevisionDuJourMeme: Int?
    
    let timeseries = json["properties"]["timeseries"].arrayValue
    for objetPrevision in timeseries {
      guard let heurePrevision = dateFormatter.date(from: objetPrevision["time"].stringValue) else {
        continue
      }
      
      // Créer la prévision horaire
      
      var previsionHoraireEnEdition = Prevision()
      previsionHoraireEnEdition.type = .horaire
      previsionHoraireEnEdition.source = .yrNo
      previsionHoraireEnEdition.heureDebut = heurePrevision
      previsionHoraireEnEdition.heureEmission = heureEmission
      
      let donneesInstantanees = objetPrevision["data"]["instant"]["details"]
      previsionHoraireEnEdition.pression = donneesInstantanees["air_pressure_at_sea_level"].doubleValue / 10 // divisé par 10 car présenté en hPa
      previsionHoraireEnEdition.temperature = donneesInstantanees["air_temperature"].doubleValue
      previsionHoraireEnEdition.pointDeRosee = donneesInstantanees["dew_point_temperature"].doubleValue
      previsionHoraireEnEdition.humidite = donneesInstantanees["relative_humidity"].doubleValue
      previsionHoraireEnEdition.indiceUV = donneesInstantanees["ultraviolet_index_clear_sky"].doubleValue
      previsionHoraireEnEdition.directionVentDegres = donneesInstantanees["wind_from_direction"].doubleValue
      previsionHoraireEnEdition.vitesseVent = donneesInstantanees["wind_speed"].doubleValue
      
      let codeSymboleCondition = objetPrevision["data"]["next_1_hours"]["summary"]["symbol_code"].stringValue
      if codeSymboleCondition != "" {
        let composants = codeSymboleCondition.components(separatedBy: "_")
        let chaineCondition = composants[0]
        previsionHoraireEnEdition.chaineCondition = chaineCondition
        previsionHoraireEnEdition.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
        if previsionHoraireEnEdition.condition == nil {
          print("Incapable de parser la condition yr.no \(chaineCondition)")
        }
      }
      
      previsionHoraireEnEdition.quantitePrecipitation = objetPrevision["data"]["next_1_hours"]["details"]["precipitation_amount"].doubleValue
      
      // Ajouter la prévision horaire
      previsionsParHeure[heurePrevision] = previsionHoraireEnEdition
      
      // Pour les prévisions par jour, c'est un peu plus compliqué
      
      let heureActuelle = Date()
      let calendrierLocal = Calendar.current
      //calendar.timeZone = timeZone du lieu de la prévision
      let intHeureLocalePrevision = calendrierLocal.component(.hour, from: heurePrevision)
      let intHeureLocaleActuelle = calendrierLocal.component(.hour, from: heureActuelle)
      let joursDeLaSemaine = calendrierLocal.weekdaySymbols

      var calendrierUTC = Calendar.current
      calendrierUTC.timeZone = TimeZone(identifier: "UTC")!
      let intHeureUTCPrevision = calendrierUTC.component(.hour, from: heurePrevision)
      
      // Créer la prévision pour le reste de la journée ou nuit actuelle.
      // Si l'heure locale actuelle est entre 4 et 6h inclus, ou 16 et 18h inclus, on ne montre pas cette prévision (on passe directement à la journée ou la nuit suivante)
      if !aCreePrevisionDuJourMeme,
          (intHeureLocaleActuelle > 6 && intHeureLocaleActuelle < 16) /* jour */ ||
          (intHeureLocaleActuelle > 18 || intHeureLocaleActuelle < 4) /* nuit */ {
        
        previsionJourEnEdition = Prevision()
        previsionJourEnEdition!.type = .quotidien
        previsionJourEnEdition!.source = .yrNo
        let heureAjustee = calendrierLocal.date(bySettingHour: (intHeureLocaleActuelle > 18 || intHeureLocaleActuelle < 4) ? 18 : 6, minute: 0, second: 0, of: heurePrevision)
        previsionJourEnEdition!.heureDebut = heureAjustee
        previsionJourEnEdition!.heureEmission = heureEmission

        var chaineJourDeLaSemaine = joursDeLaSemaine[calendrierLocal.component(.weekday, from: heurePrevision) - 1]
        if (intHeureLocaleActuelle > 18 || intHeureLocaleActuelle < 4) {
          chaineJourDeLaSemaine = chaineJourDeLaSemaine + " night"
        }
        previsionJourEnEdition!.chainePeriode = chaineJourDeLaSemaine
        // il faudrait une fonction pour changer le jour en today/tonight si c'est pertinent
        //        if let heureAjustee = heureAjustee, calendrierLocal.component(.hour, from: heureAjustee) == 18 {
        //          previsionJourEnEdition!.chainePeriode = "Tonight"
        //        } else {
        //          previsionJourEnEdition!.chainePeriode = "Today"
        //        }
        
        // La condition est soit celle des 6 ou des 12 prochaines heures, selon si on est assez tôt dans la journée/nuit
        var codeSymboleCondition: String
        if (intHeureLocaleActuelle > 6 && intHeureLocaleActuelle <= 12) || (intHeureLocaleActuelle > 18) {
          codeSymboleCondition = objetPrevision["data"]["next_12_hours"]["summary"]["symbol_code"].stringValue
        } else {
          codeSymboleCondition = objetPrevision["data"]["next_6_hours"]["summary"]["symbol_code"].stringValue
          doitAjusterSelonDeuxiemePeriodeDe6h = true
        }
        if codeSymboleCondition != "" {
          let composants = codeSymboleCondition.components(separatedBy: "_")
          let chaineCondition = composants[0]
          previsionJourEnEdition!.chaineCondition = chaineCondition
          previsionJourEnEdition!.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
          if previsionJourEnEdition!.condition == nil {
            print("Incapable de parser la condition \(chaineCondition)")
          }
        }
        
        previsionJourEnEdition!.temperatureMin = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_min"].doubleValue
        previsionJourEnEdition!.temperatureMax = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_max"].doubleValue
        previsionJourEnEdition!.quantitePrecipitation = objetPrevision["data"]["next_6_hours"]["details"]["precipitation_amount"].doubleValue
        
        previsionsParJour[heureAjustee!] = previsionJourEnEdition
        aCreePrevisionDuJourMeme = true
        intHeurePrevisionDuJourMeme = intHeureUTCPrevision
        continue
      }
      
      // Si la prévision pour le jour même utilise la condition des next_12_hours, on va regarder la 2e période de 6h pour ajuster la température et les précipitations.
      if doitAjusterSelonDeuxiemePeriodeDe6h,
        let intHeurePrevisionDuJourMeme = intHeurePrevisionDuJourMeme,
        (intHeureUTCPrevision - intHeurePrevisionDuJourMeme) % 24 == 6 {
        
        let temperatureMin = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_min"].doubleValue
        let temperatureMax = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_max"].doubleValue
        if temperatureMin < previsionJourEnEdition!.temperatureMin ?? -999 {
          previsionJourEnEdition!.temperatureMin = temperatureMin
        }
        if temperatureMax > previsionJourEnEdition!.temperatureMax ?? -999 {
          previsionJourEnEdition!.temperatureMax = temperatureMax
        }
        let precipitationsAvant = previsionJourEnEdition!.quantitePrecipitation ?? 0
        previsionJourEnEdition!.quantitePrecipitation = precipitationsAvant + objetPrevision["data"]["next_6_hours"]["details"]["precipitation_amount"].doubleValue
        
        previsionsParJour[previsionJourEnEdition!.heureDebut] = previsionJourEnEdition
        doitAjusterSelonDeuxiemePeriodeDe6h = false
        continue
      }
      
      // Créer une prévision pour un jour ou une nuit à partir de next_12_hours et next_6_hours.
      // Si on est dans le fuseau UTC, ceci devrait remplir tout.
      // Ailleurs, ça va remplir seulement environ 2 jours parce que les prévisions plus lointaines sont mal alignées.
      if (intHeureLocalePrevision == 6 || intHeureLocalePrevision == 18), objetPrevision["data"]["next_12_hours"].exists() || objetPrevision["data"]["next_6_hours"].exists() {
        previsionJourEnEdition = Prevision()
        previsionJourEnEdition!.type = .quotidien
        previsionJourEnEdition!.source = .yrNo
        previsionJourEnEdition!.heureDebut = heurePrevision
        previsionJourEnEdition!.heureEmission = heureEmission
        
        var chaineJourDeLaSemaine = joursDeLaSemaine[calendrierLocal.component(.weekday, from: heurePrevision) - 1]
        if intHeureLocalePrevision == 18 {
          chaineJourDeLaSemaine = chaineJourDeLaSemaine + " night"
        }
        previsionJourEnEdition!.chainePeriode = chaineJourDeLaSemaine
        
        var codeSymboleCondition: String
        if objetPrevision["data"]["next_12_hours"].exists() {
          codeSymboleCondition = objetPrevision["data"]["next_12_hours"]["summary"]["symbol_code"].stringValue
        } else {
          codeSymboleCondition = objetPrevision["data"]["next_6_hours"]["summary"]["symbol_code"].stringValue
        }
        if codeSymboleCondition != "" {
          let composants = codeSymboleCondition.components(separatedBy: "_")
          let chaineCondition = composants[0]
          previsionJourEnEdition!.chaineCondition = chaineCondition
          previsionJourEnEdition!.condition = Condition(rawValue: chaineCondition)
          if previsionJourEnEdition!.condition == nil {
            print("Incapable de parser la condition \(chaineCondition)")
          }
        }
        
        previsionJourEnEdition!.temperatureMin = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_min"].doubleValue
        previsionJourEnEdition!.temperatureMax = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_max"].doubleValue
        previsionJourEnEdition!.quantitePrecipitation = objetPrevision["data"]["next_6_hours"]["details"]["precipitation_amount"].doubleValue
        
        previsionsParJour[heurePrevision] = previsionJourEnEdition
        continue
      }
      
      // Ajustement en utilisant le next_6_hours de minuit ou midi
      if (intHeureLocalePrevision == 0 || intHeureLocalePrevision == 12), objetPrevision["data"]["next_6_hours"].exists() {
        let temperatureMin = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_min"].doubleValue
        let temperatureMax = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_max"].doubleValue
        if temperatureMin < previsionJourEnEdition!.temperatureMin ?? -999 {
          previsionJourEnEdition!.temperatureMin = temperatureMin
        }
        if temperatureMax > previsionJourEnEdition!.temperatureMax ?? -999 {
          previsionJourEnEdition!.temperatureMax = temperatureMax
        }
        let precipitationsAvant = previsionJourEnEdition!.quantitePrecipitation ?? 0
        previsionJourEnEdition!.quantitePrecipitation = precipitationsAvant + objetPrevision["data"]["next_6_hours"]["details"]["precipitation_amount"].doubleValue
        
        previsionsParJour[previsionJourEnEdition!.heureDebut] = previsionJourEnEdition
        continue
      }
      
      // Pour la période à long terme, sans prévisions horaires, créer des prévisions à partir des next_12_hours et ajuster avec les next_6_hours.
      // Les prévisions de yr.no sont toujours à 0h, 6h, 12h et 18h UTC.
      // On utilise l'heure locale pour déterminer si c'est la prévision du matin (6-11h) ou du soir (18-23h) ou l'ajustement de l'après-midi (12-17h) ou de la nuit (0-5h)
      if !objetPrevision["data"]["next_1_hours"].exists() {
        
        switch intHeureLocalePrevision {
        case 6, 7, 8, 9, 10, 11, 18, 19, 20, 21, 22, 23:
          previsionJourEnEdition = Prevision()
          previsionJourEnEdition!.type = .quotidien
          previsionJourEnEdition!.source = .yrNo
          let heureAjustee = calendrierLocal.date(bySettingHour: intHeureLocalePrevision >= 18 ? 18 : 6, minute: 0, second: 0, of: heurePrevision)
          previsionJourEnEdition!.heureDebut = heureAjustee
          previsionJourEnEdition!.heureEmission = heureEmission
          
          var chaineJourDeLaSemaine = joursDeLaSemaine[calendrierLocal.component(.weekday, from: heurePrevision) - 1]
          if intHeureLocalePrevision >= 18 {
            chaineJourDeLaSemaine = chaineJourDeLaSemaine + " night"
          }
          previsionJourEnEdition!.chainePeriode = chaineJourDeLaSemaine
          
          var codeSymboleCondition: String
          if objetPrevision["data"]["next_12_hours"].exists() {
            codeSymboleCondition = objetPrevision["data"]["next_12_hours"]["summary"]["symbol_code"].stringValue
          } else {
            codeSymboleCondition = objetPrevision["data"]["next_6_hours"]["summary"]["symbol_code"].stringValue
          }
          if codeSymboleCondition != "" {
            let composants = codeSymboleCondition.components(separatedBy: "_")
            let chaineCondition = composants[0]
            previsionJourEnEdition!.chaineCondition = chaineCondition
            previsionJourEnEdition!.condition = Condition(rawValue: nettoyerChaineCondition(chaineCondition))
            if previsionJourEnEdition!.condition == nil {
              print("Incapable de parser la condition \(chaineCondition)")
            }
          }
          
          previsionJourEnEdition!.temperatureMin = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_min"].doubleValue
          previsionJourEnEdition!.temperatureMax = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_max"].doubleValue
          previsionJourEnEdition!.quantitePrecipitation = objetPrevision["data"]["next_6_hours"]["details"]["precipitation_amount"].doubleValue
          
          previsionsParJour[heureAjustee!] = previsionJourEnEdition
          continue
          
        case 12, 13, 14, 15, 16, 17, 0, 1, 2, 3, 4, 5:
          let temperatureMin = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_min"].doubleValue
          let temperatureMax = objetPrevision["data"]["next_6_hours"]["details"]["air_temperature_max"].doubleValue
          if temperatureMin < previsionJourEnEdition!.temperatureMin ?? -999 {
            previsionJourEnEdition!.temperatureMin = temperatureMin
          }
          if temperatureMax > previsionJourEnEdition!.temperatureMax ?? -999 {
            previsionJourEnEdition!.temperatureMax = temperatureMax
          }
          let precipitationsAvant = previsionJourEnEdition!.quantitePrecipitation ?? 0
          previsionJourEnEdition!.quantitePrecipitation = precipitationsAvant + objetPrevision["data"]["next_6_hours"]["details"]["precipitation_amount"].doubleValue
          
          previsionsParJour[previsionJourEnEdition!.heureDebut] = previsionJourEnEdition
          continue
          
        default:
          break
        }
      }
    }
    
    completionHandler(nil, previsionsParJour, previsionsParHeure)
  }
}

// Identifier la sorte de sleet
private func nettoyerChaineCondition(_ chaine: String) -> String {
  var chaineNettoyee = chaine.lowercased()
  // Identifier la sorte de sleet (pour yr.no, ça semble être un mélange de pluie et de neige)
  if chaineNettoyee.contains("sleet") {
    chaineNettoyee = chaineNettoyee + " (rain and snow)"
  }
  return chaineNettoyee
}

