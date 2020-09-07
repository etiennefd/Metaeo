//
//  DelegueParseurXML.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-20.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class DelegueParseurXMLEnvironnementCanada: NSObject, DelegueParseurXML {  
  
  //Pour le parsage XML :
  var elementXMLEnEdition: ElementXML? // pour savoir ce qu'on est en train d'éditer
  var conditionsActuelles: Prevision!
  var previsionsParJour: [Date : Prevision]!
  var previsionsParHeure: [Date : Prevision]!
  var previsionEnEdition: Prevision!
  
  // Dates/heures
  var heureCreationXML = Date()
  var heureLocaleCreationXML = Date()
  var fuseauHoraire: TimeZone!
  var heureEmissionForecast: Date?
  var heureEmissionHourlyForecast: Date?
  var heureLeverDuSoleil: Date?
  var heureCoucherDuSoleil: Date?
  var dateFormatterHourlyForecast = DateFormatter()
  var dateFormatterTimeStamp = DateFormatter()
  
  //MARK: XMLParserDelegate
  // voir https://stackoverflow.com/questions/31083348/parsing-xml-from-url-in-swift
  
  func parserDidStartDocument(_ parser: XMLParser) {
    // Paramétrer les dateFormatter
    self.dateFormatterHourlyForecast.dateFormat = "yyyyMMddHHmm"
    self.dateFormatterHourlyForecast.timeZone = TimeZone(secondsFromGMT: 0)
    self.dateFormatterTimeStamp.dateFormat = "yyyyMMddHHmmss"
    self.dateFormatterTimeStamp.timeZone = TimeZone(secondsFromGMT: 0)
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    // créer un nouvel élément XML
    let nouvelElementXML = ElementXML()
    nouvelElementXML.nom = elementName
    nouvelElementXML.attributs = attributeDict
    nouvelElementXML.parent = self.elementXMLEnEdition
    self.elementXMLEnEdition = nouvelElementXML
    // créer les objets si l'on est au début d'une nouvelle prévision dans le XML
    switch elementName {
    case "forecastGroup":
      previsionsParJour = [Date : Prevision]()
    case "hourlyForecastGroup":
      previsionsParHeure = [Date : Prevision]()
    case "currentConditions", "forecast", "hourlyForecast":
      previsionEnEdition = Prevision()
    default: break
    }
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let elementXML = (self.elementXMLEnEdition?.parent?.nom, self.elementXMLEnEdition?.nom) // tuple
    if !data.isEmpty {
      switch elementXML {
      case (_, "condition") /*currentConditions et hourlyForecast*/, ("abbreviatedForecast", "textSummary") /*forecast*/:
        self.previsionEnEdition.condition = Condition(rawValue: nettoyerChaineCondition(data))
        if self.previsionEnEdition.condition == nil {
          print("Incapable de parser la condition EC \(data)")
        }
        self.previsionEnEdition.chaineCondition = data
      case ("forecast", "textSummary"):
        self.previsionEnEdition.detailsCondition = data
      case (_, "dewpoint"):
        if let pointDeRosee = Double(data) {
          self.previsionEnEdition.pointDeRosee = Measurement(value: pointDeRosee, unit: UnitTemperature.celsius)
        }
      case (_, "humidex") /*currentConditions et hourlyForecast*/, ("humidex", "calculated") /*forecase*/:
        if let humidex = Double(data) {
          self.previsionEnEdition.humidex = Measurement(value: humidex, unit: UnitTemperature.celsius)
        }
      case (_, "lop"):
        self.previsionEnEdition.probPrecipitation = Double(data)
      case (_, "period"):
        self.previsionEnEdition.chainePeriode = data
      case (_, "pressure"):
        if let pression = Double(data) {
          self.previsionEnEdition.pression = Measurement(value: pression, unit: UnitPressure.kilopascals)
        }
        self.previsionEnEdition.tendancePression = TendancePression(rawValue: self.elementXMLEnEdition?.attributs["tendency"] ?? "")
        if let changementPression = Double(self.elementXMLEnEdition?.attributs["change"] ?? "") {
          self.previsionEnEdition.changementPression = Measurement(value: changementPression, unit: UnitPressure.kilopascals)
        }
      case (_, "pop"):
        self.previsionEnEdition.probPrecipitation = Double(data)
      case (_, "relativeHumidity"):
        self.previsionEnEdition.humidite = Double(data)
      case (_, "temperature"): // parent == "temperatures" pour forecast et currentConditions, mais pas pour hourlyForecast
        if self.elementXMLEnEdition?.attributs["class"] == "high", let temperatureMax = Double(data) {
          self.previsionEnEdition.temperatureMax = Measurement(value: temperatureMax, unit: UnitTemperature.celsius)
        } else if self.elementXMLEnEdition?.attributs["class"] == "low", let temperatureMin = Double(data) {
          self.previsionEnEdition.temperatureMin = Measurement(value: temperatureMin, unit: UnitTemperature.celsius)
        } else if let temperature = Double(data) {
          self.previsionEnEdition.temperature = Measurement(value: temperature, unit: UnitTemperature.celsius)
        }
      case (_, "visibility"):
        if let visibilite = Double(data) {
          self.previsionEnEdition.visibilite = Measurement(value: visibilite, unit: UnitLength.kilometers)
        }
      case (_, "windChill"):
        if let refroidissementEolien = Double(data) {
          self.previsionEnEdition.refroidissementEolien = Measurement(value: refroidissementEolien, unit: UnitTemperature.celsius)
        }
      case ("uv", "index"):
        self.previsionEnEdition.indiceUV = Double(data)
      case ("wind", "speed"):
        if let vitesseVent = Double(data) {
          self.previsionEnEdition.vitesseVent = Measurement(value: vitesseVent, unit: UnitSpeed.kilometersPerHour)
        }
      case ("wind", "gust"):
        if let vitesseRafales = Double(data) {
          self.previsionEnEdition.vitesseRafales = Measurement(value: vitesseRafales, unit: UnitSpeed.kilometersPerHour)
        }
      case ("wind", "direction"):
        self.previsionEnEdition.directionVent = PointCardinal(rawValue: data)
      case ("dateTime", "timeStamp"):
        // heure de création du XML : heure universelle
        if self.elementXMLEnEdition?.parent?.attributs["name"] == "xmlCreation",
          self.elementXMLEnEdition?.parent?.attributs["zone"] == "UTC" {
          self.heureCreationXML = self.dateFormatterTimeStamp.date(from: data) ?? Date()
        }
        // heure de création du XML : heure locale
        if self.elementXMLEnEdition?.parent?.attributs["name"] == "xmlCreation",
          self.elementXMLEnEdition?.parent?.attributs["zone"] != "UTC",
          let differenceAvecUTC = self.elementXMLEnEdition?.parent?.attributs["UTCOffset"] {
          self.heureLocaleCreationXML = self.dateFormatterTimeStamp.date(from: data) ?? Date()
          self.fuseauHoraire = TimeZone(secondsFromGMT: Int(differenceAvecUTC)! * 3600)
        }
 
        // heure de l'observation des conditions actuelles
        else if self.elementXMLEnEdition?.parent?.attributs["name"] == "observation",
          self.elementXMLEnEdition?.parent?.attributs["zone"] == "UTC" {
          let heureObservation = self.dateFormatterTimeStamp.date(from: data)
//          self.previsionEnEdition.heureEmission = heureEmission
          self.previsionEnEdition.heureDebut = heureObservation
        }
        // heure de l'émission des prévisions
        else if self.elementXMLEnEdition?.parent?.attributs["name"] == "forecastIssue",
          self.elementXMLEnEdition?.parent?.attributs["zone"] == "UTC" {
          let heureEmission = self.dateFormatterTimeStamp.date(from: data)
          if self.elementXMLEnEdition?.parent?.parent?.nom == "forecastGroup" {
            self.heureEmissionForecast = heureEmission
          } else if self.elementXMLEnEdition?.parent?.parent?.nom == "hourlyForecastGroup" {
            self.heureEmissionHourlyForecast = heureEmission
          }
        }
        // heure du lever de soleil
        else if self.elementXMLEnEdition?.parent?.attributs["name"] == "sunrise",
          self.elementXMLEnEdition?.parent?.attributs["zone"] == "UTC" {
          self.heureLeverDuSoleil = self.dateFormatterTimeStamp.date(from: data)
        }
        // heure du coucher de soleil
        else if self.elementXMLEnEdition?.parent?.attributs["name"] == "sunset",
          self.elementXMLEnEdition?.parent?.attributs["zone"] == "UTC" {
          self.heureCoucherDuSoleil = self.dateFormatterTimeStamp.date(from: data)
        }
      default: break
      }
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if self.previsionEnEdition != nil {
      self.previsionEnEdition.source = .environnementCanada
    }
    switch elementName {
    case "currentConditions":
      self.previsionEnEdition.type = .actuel
      self.previsionEnEdition.heureEmission = self.heureEmissionForecast
      self.conditionsActuelles = self.previsionEnEdition
    case "forecast":
      // Cas spécial : parfois, EC donne "chance of showers" mais mentionne un risque d'orages dans le texte et met une icône avec de la foudre.
      // Lorsque ça se produit, je change la condition pour inclure le risque d'orages.
      if self.previsionEnEdition.condition == .chanceOfShowers, self.previsionEnEdition.detailsCondition?.contains("thunderstorm") ?? false {
        self.previsionEnEdition.condition = .chanceOfShowersOrThunderstorms
      }
      self.previsionEnEdition.type = .quotidien
      if let chaineJour = self.previsionEnEdition.chainePeriode {
        if let jour = dateDepuisChaineJour(chaineJour) {
          self.previsionEnEdition.heureDebut = jour
          self.previsionsParJour![jour] = self.previsionEnEdition
        }
      }
    case "hourlyForecast":
      self.previsionEnEdition.type = .horaire
      self.previsionEnEdition.heureEmission = self.heureEmissionHourlyForecast
      if let chaineHeure = self.elementXMLEnEdition?.attributs["dateTimeUTC"],
        let heure = self.dateFormatterHourlyForecast.date(from: chaineHeure) {
        self.previsionEnEdition.chainePeriode = chaineHeure
        self.previsionEnEdition.heureDebut = heure
        self.previsionsParHeure![heure] = self.previsionEnEdition
      }
    default: break
    }
    if let parent = self.elementXMLEnEdition?.parent {
      self.elementXMLEnEdition = parent
    }
  }
  
  // Convertit par exemple "Wednesday night" en Date en utilisant la date de création du XML
  private func dateDepuisChaineJour(_ chaine: String) -> Date? {
    var calendrierAnglais = Calendar.current
    calendrierAnglais.locale = Locale(identifier: "en_US_POSIX")
    let joursDeLaSemaine = calendrierAnglais.weekdaySymbols
    let indexJourActuel = calendrierAnglais.component(.weekday, from: self.heureLocaleCreationXML) - 1
    let composantsChaine = chaine.components(separatedBy: " ")
    let symboleJourDeLaChaine = composantsChaine[0]
    guard let indexJourDeLaChaine = joursDeLaSemaine.firstIndex(of: symboleJourDeLaChaine) else {
      return nil
    }
    // Le décalage représente le nombre de jours (ex. 4) entre la date de la prévision (ex. jeudi) et aujourd'hui (ex. lundi)
    let decalage = ((indexJourDeLaChaine + joursDeLaSemaine.count) - indexJourActuel) % joursDeLaSemaine.count
    var composantDateDecalage = DateComponents()
    composantDateDecalage.day = decalage
    guard let dateDecalee = Calendar.current.date(byAdding: composantDateDecalage, to: self.heureLocaleCreationXML) else {
      return nil
    }
    // Si la prévision concerne le soir, son heure est 18h. Sinon, 6h. (Ces heures sont artificielles, pour harmoniser avec les autres sources)
    let estSoir = composantsChaine.contains("night")
    let dateAjustee = Calendar.current.date(bySettingHour: estSoir ? 18 : 6, minute: 0, second: 0, of: dateDecalee)
    return dateAjustee
  }
}

// Mettre une condition en minuscules et enlever le point final s'il y a lieu
private func nettoyerChaineCondition(_ chaine: String) -> String {
  var chaineNettoyee = chaine.lowercased()
  chaineNettoyee = chaineNettoyee.trimmingCharacters(in: .whitespaces)
  if chaineNettoyee.last == "." {
    chaineNettoyee = String(chaineNettoyee.dropLast())
  }
  return chaineNettoyee
}
