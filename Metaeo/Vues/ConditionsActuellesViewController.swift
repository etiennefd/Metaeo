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
      self.etiquetteTemperature.text = "\(conditionsActuelles.donneTemperatureArrondie()) °C"
      self.iconeCondition.image = conditionsActuelles.donneIcone()
      if let condition = conditionsActuelles.condition {
        self.etiquetteCondition.text = condition.rawValue
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
        self.etiquetteRafales.isHidden = false
        self.etiquetteRafales.text = "\(vitesseRafales) km/h"
      } else {
        self.etiquetteRafales.isHidden = true
      }
      if let humidite = conditionsActuelles.humidite {
        self.etiquetteHumidite.text = "\(humidite) %"
      }
      if let pointDeRosee = conditionsActuelles.pointDeRosee {
        self.etiquettePointDeRosee.text = "\(pointDeRosee) °C"
      }
      if let indiceUV = conditionsActuelles.indiceUV {
        self.etiquetteIndiceUV.isHidden = false
        self.etiquetteIndiceUV.text = "\(indiceUV) (???)"
      } else {
        self.etiquetteIndiceUV.isHidden = true
      }
      if let visibilite = conditionsActuelles.visibilite {
        self.etiquetteVisibilite.text = "\(visibilite) km"
      }
    }
  }
  
  //MARK: Actions
  
  @IBAction func reimporterDonnees(_ sender: Any) {
    ImportateurPrevisions.global.importePrevisions()
    self.rechargeDonnees()
  }
  
}

