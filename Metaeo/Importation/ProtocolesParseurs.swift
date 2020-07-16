//
//  ProtocolesParseurs.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-16.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

// Classe utilisée lors du parsage d'un fichier XML
class ElementXML {
  var nom: String = ""
  var attributs: [String : String] = [:]
  var parent: ElementXML?
}

// Protocole pour le parsage XML, utilisant le protocole XMLParserDelegate mais y ajoutant des propriétés
protocol DelegueParseurXML: XMLParserDelegate {
  var conditionsActuelles: Prevision! { get }
  var previsionsParJour: [Date : Prevision]! { get }
  var previsionsParHeure: [Date : Prevision]! { get }
  var heureLeverDuSoleil: Date? { get }
  var heureCoucherDuSoleil: Date? { get }
  var heureCreationXML: Date { get }
  var fuseauHoraire: TimeZone! { get }
}

// Protocole pour le parsage d'un JSON
protocol ParseurJSON {
  var conditionsActuelles: Prevision? { get }
  var previsionsParJour: [Date : Prevision]! { get }
  var previsionsParHeure: [Date : Prevision]! { get }
  
  func parseJSON(_ json: JSON) 
}
