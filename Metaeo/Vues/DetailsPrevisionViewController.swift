//
//  DetailsPrevisionViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-12.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class DetailsPrevisionViewController: UIViewController {
  
  //MARK: Properties
  var previsionAffichee: Prevision!

  @IBOutlet weak var etiquettePrevision: UILabel!
  @IBOutlet weak var etiquetteSource: UILabel!
  @IBOutlet weak var iconeCondition: UIImageView!
  @IBOutlet weak var etiquetteTemperature: UILabel!
  @IBOutlet weak var etiquetteTemperatureRessentie: UILabel!
  @IBOutlet weak var etiquetteCondition: UILabel!
  @IBOutlet weak var etiquetteProbPrecipitation: UILabel!
  @IBOutlet weak var etiquetteDetails: UILabel!
  @IBOutlet weak var etiquetteIndiceUV: UILabel!
  @IBOutlet weak var etiquetteVent: UILabel!
  @IBOutlet weak var etiquetteHeureEmission: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    if let prevision = self.previsionAffichee {
      self.etiquettePrevision.text = "Forecast for \(prevision.donneChainePeriode() ?? "???") in \(prevision.lieu ?? "???")"
      self.etiquetteSource.text = "Source: \(prevision.source.rawValue)"
      self.iconeCondition.image = prevision.donneIcone()
      self.etiquetteTemperature.text = "\(prevision.donneChaineTemperature())" // à faire : afficher max ou min?
      if let temperatureRessentie = prevision.donneTemperatureRessentieArrondie() {
        self.etiquetteTemperatureRessentie.text = "Feels like \(temperatureRessentie)"
      }
      if let condition = prevision.condition {
        self.etiquetteCondition.text = condition.rawValue
      }
      if let probPrecipitation = prevision.probPrecipitation {
        self.etiquetteProbPrecipitation.text = "Chance of precipitation: \(probPrecipitation)%"
      }
      if let detailsCondition = prevision.detailsCondition {
        self.etiquetteDetails.text = "\(detailsCondition)"
      }
      if let indiceUV = prevision.donneIndiceUV() {
        self.etiquetteIndiceUV.text = "Indice UV: \(indiceUV)"
      }
      if let chaineVitesseVent = prevision.donneChaineVitesseVentArrondie() {
        self.etiquetteVent.text = "Wind: \(chaineVitesseVent)"
        if let vitesseRafales = prevision.vitesseRafales {
          self.etiquetteVent.text?.append(" gusting at \(Int(vitesseRafales.rounded())) km/h")
        }
      }
      self.etiquetteHeureEmission.text = "Forecast issued at \(prevision.donneChaineHeureEmission() ?? "???")"
    }
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
