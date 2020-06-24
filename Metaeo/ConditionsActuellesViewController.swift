//
//  ConditionsActuellesViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class ConditionsActuellesViewController: UIViewController {
  
  //MARK: Properties
  //var conditionsActuelles: Prevision!
  
  @IBOutlet weak var iconeCondition: UIImageView!
  @IBOutlet weak var etiquetteTemperature: UILabel!
  @IBOutlet weak var etiquetteCondition: UILabel!
  @IBOutlet weak var etiquettePression: UILabel!
  @IBOutlet weak var etiquetteVent: UILabel!
  @IBOutlet weak var etiquetteRafales: UILabel!
  @IBOutlet weak var etiquetteHumidite: UILabel!
  @IBOutlet weak var etiquettePointDeRosee: UILabel!
  @IBOutlet weak var etiquetteIndiceUV: UILabel!
  @IBOutlet weak var etiquetteVisibilite: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    rechargeDonnees()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    rechargeDonnees()
  }
  
  func rechargeDonnees() {
    if let conditionsActuelles = ImportateurPrevisions.global.conditionsActuelles {
      if let temperature = conditionsActuelles.temperature {
        self.etiquetteTemperature.text = "\(temperature) °C"
      }
      if let condition = conditionsActuelles.condition {
        self.etiquetteTemperature.text = "\(condition)"
      }
      if let pression = conditionsActuelles.pression,
        let tendancePression = conditionsActuelles.tendancePression {
        self.etiquettePression.text = "\(pression) kPa, \(tendancePression)"
      }
      if let vitesseVent = conditionsActuelles.vitesseVent,
        let directionVent = conditionsActuelles.directionVent {
        self.etiquetteVent.text = "\(vitesseVent) km/h \(directionVent)"
      }
      if let vitesseRafales = conditionsActuelles.vitesseRafales {
        self.etiquetteRafales.text = "\(vitesseRafales) km/h"
      }
      if let humidite = conditionsActuelles.humidite {
        self.etiquetteHumidite.text = "\(humidite) %"
      }
      if let pointDeRosee = conditionsActuelles.pointDeRosee {
        self.etiquettePointDeRosee.text = "\(pointDeRosee) °C"
      }
      if let indiceUV = conditionsActuelles.indiceUV {
        self.etiquetteIndiceUV.text = "\(indiceUV) (???)"
      }
      if let visibilite = conditionsActuelles.visibilite {
        self.etiquetteVisibilite.text = "\(visibilite) km"
      }
    }
  }
  
  //MARK: Actions
  
  
}

