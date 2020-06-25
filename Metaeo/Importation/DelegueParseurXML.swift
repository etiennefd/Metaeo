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
  var previsionsParJour: [String : Prevision]! // changer String pour Date?
  var previsionsParHeure: [String : Prevision]! // changer String pour Date?
  var previsionEnEdition: Prevision!
  
  //MARK: XMLParserDelegate
  // voir https://stackoverflow.com/questions/31083348/parsing-xml-from-url-in-swift
  
  func parserDidStartDocument(_ parser: XMLParser) {
    
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
      previsionsParJour = [String : Prevision]()
    case "hourlyForecastGroup":
      previsionsParHeure = [String : Prevision]()
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
        self.previsionEnEdition.periode = data
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
      if let jour = self.previsionEnEdition.periode {
        self.previsionsParJour![jour] = self.previsionEnEdition
      }
    case "hourlyForecast":
      if let heure = self.elementXMLEnEdition?.attributs["dateTimeUTC"] {
        self.previsionEnEdition.periode = heure
        self.previsionsParHeure![heure] = self.previsionEnEdition
      }
    default: break
    }
    if let parent = self.elementXMLEnEdition?.parent {
      self.elementXMLEnEdition = parent
    }
  }
}


