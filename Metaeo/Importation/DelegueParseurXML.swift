//
//  DelegueParseurXML.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-06-20.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

class ElementXML {
  var nom: String = ""
  var attributs: [String : String] = [:]
  var parent: ElementXML?
}

class DelegueParseurXML: NSObject, XMLParserDelegate {
  
  //Pour le parsage XML :
  var elementXMLEnEdition: ElementXML? // pour savoir ce qu'on est en train d'éditer
  var conditionsActuelles: Prevision!
  var previsionsParJour: [Date : Prevision]!
  var previsionsParHeure: [Date : Prevision]!
  var previsionEnEdition: Prevision!
  
  // Dates
  var dateEmissionLocale = Date()
  var fuseauHoraire: TimeZone!
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
        self.previsionEnEdition.condition = Condition(rawValue: data)
      case (_, "dewpoint"):
        self.previsionEnEdition.pointDeRosee = Double(data)
      case (_, "period"):
        self.previsionEnEdition.chainePeriode = data
      case (_, "pressure"):
        self.previsionEnEdition.pression = Double(data)
        self.previsionEnEdition.tendancePression = TendancePression(rawValue: self.elementXMLEnEdition?.attributs["tendency"] ?? "")
        self.previsionEnEdition.changementPression = Double(self.elementXMLEnEdition?.attributs["change"] ?? "")
      case (_, "relativeHumidity"):
        self.previsionEnEdition.humidite = Double(data)
      case (_, "temperature"): // parent == "temperatures" pour forecast et currentConditions, mais pas pour hourlyForecast
        if self.elementXMLEnEdition?.attributs["class"] == "high" {
          self.previsionEnEdition.temperatureMax = Double(data)
        } else if self.elementXMLEnEdition?.attributs["class"] == "low" {
          self.previsionEnEdition.temperatureMin = Double(data)
        } else {
          self.previsionEnEdition.temperature = Double(data)
        }
      case (_, "visibility"):
        self.previsionEnEdition.visibilite = Double(data)
      case ("uv", "index"):
        self.previsionEnEdition.indiceUV = Int(data)
      case ("wind", "speed"):
        self.previsionEnEdition.vitesseVent = Int(data)
      case ("wind", "gust"):
        self.previsionEnEdition.vitesseRafales = Int(data)
      case ("wind", "direction"):
        self.previsionEnEdition.directionVent = PointCardinal(rawValue: data)
      case ("dateTime", "timeStamp"):
        if self.elementXMLEnEdition?.parent?.attributs["name"] == "xmlCreation",
          self.elementXMLEnEdition?.parent?.attributs["zone"] != "UTC",
          let differenceAvecUTC = self.elementXMLEnEdition?.parent?.attributs["UTCOffset"] {
          self.dateEmissionLocale = self.dateFormatterTimeStamp.date(from: data) ?? Date()
          self.fuseauHoraire = TimeZone(secondsFromGMT: Int(differenceAvecUTC)! * 3600)
        }
      default: break
      }
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if self.previsionEnEdition != nil {
      self.previsionEnEdition.source = "Environnement Canada" // à déplacer et ajuster selon la source
    }
    switch elementName {
    case "currentConditions":
      self.conditionsActuelles = self.previsionEnEdition
    case "forecast":
      if let chaineJour = self.previsionEnEdition.chainePeriode {
        if let jour = dateDepuisChaineJour(chaineJour) {
          self.previsionEnEdition.heureDebut = jour
          self.previsionsParJour![jour] = self.previsionEnEdition
        }
      }
    case "hourlyForecast":
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
  
  // Convertit par exemple "Wednesday night" en Date en utilisant la date d'émission de la prévision
  private func dateDepuisChaineJour(_ chaine: String) -> Date? {
    let joursDeLaSemaine = Calendar.current.weekdaySymbols
    let indexJourActuel = Calendar.current.component(.weekday, from: self.dateEmissionLocale) - 1
    let composantsChaine = chaine.components(separatedBy: " ")
    let symboleJourDeLaChaine = composantsChaine[0]
    guard let indexJourDeLaChaine = joursDeLaSemaine.firstIndex(of: symboleJourDeLaChaine) else {
      return nil
    }
    let decalage = ((indexJourDeLaChaine + joursDeLaSemaine.count) - indexJourActuel) % joursDeLaSemaine.count
    var composantDateDecalage = DateComponents()
    composantDateDecalage.day = decalage
    guard let dateDecalee = Calendar.current.date(byAdding: composantDateDecalage, to: self.dateEmissionLocale) else {
      return nil
    }
    // Si la prévision concerne le soir, son heure est 16h. Sinon, 5h.
    let estSoir = composantsChaine.contains("night")
    let dateAjustee = Calendar.current.date(bySettingHour: estSoir ? 16 : 5, minute: 0, second: 0, of: dateDecalee)
    return dateAjustee
  }
}


