//
//  SecondViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class ElementXML {
  var nom: String = ""
  var attributs: [String : String] = [:]
  var parent: ElementXML?
}

class SecondViewController: UIViewController, XMLParserDelegate {

  //MARK: Properties
  //Pour le parsage XML :
  var elementXMLEnEdition: ElementXML? // pour savoir ce qu'on est en train d'éditer
  var conditionsActuelles: Prevision!
  var previsions: [Prevision]!
  var previsionsParHeure: [Prevision]!
  var previsionEnEdition: Prevision!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  //MARK: Actions
  
  @IBAction func fetchePrevision(_ sender: Any) {
    let url = URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/QC/s0000635_e.xml")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur inconnue")
        return
      }
      print(String(data: data, encoding: .utf8)!)
      // Parser le xml
      let parser = XMLParser(data: data)
      parser.delegate = self
      if parser.parse() {
        print(self.previsions ?? "No results")
      }
    }
    task.resume()
  }

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
      previsions = [Prevision]()
    case "hourlyForecastGroup":
      previsionsParHeure = [Prevision]()
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
      case ("wind", "gust"):
        self.previsionEnEdition.vitesseRafales = Int(data)
      default: break
      }
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let parent = self.elementXMLEnEdition?.parent {
      self.elementXMLEnEdition = parent
    }
    switch elementName {
    case "currentConditions":
      self.conditionsActuelles = self.previsionEnEdition
    case "forecast":
      self.previsions.append(self.previsionEnEdition)
    case "hourlyForecast":
      self.previsions.append(self.previsionEnEdition)
    default: break
    }
  }

}

