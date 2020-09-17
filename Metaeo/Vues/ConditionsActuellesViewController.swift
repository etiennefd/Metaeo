//
//  ConditionsActuellesViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit
import MapKit

class ConditionsActuellesViewController: UIViewController {
  
  //MARK: Properties
  //var conditionsActuelles: Prevision!
  var stateController: StateController!
  
  var sourceEnAffichage: SourcePrevision? = .environnementCanada //.openWeatherMap // à faire : mécanisme pour choisir par défaut une source
  var donneesEnAffichage: DonneesPourLieu?
  var conditionsActuelles: Prevision? {
    if let donneesEnAffichage = self.donneesEnAffichage, let sourceEnAffichage = self.sourceEnAffichage {
      return donneesEnAffichage.conditionsActuelles[sourceEnAffichage]
    }
    return nil
  }
  
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
  @IBOutlet weak var etiquetteSource: UILabel!
  @IBOutlet weak var etiquetteHeureEmission: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    //self.importeEtRechargeDonnees(forcerImportation: false)
    
    stateController.locationManager.delegate = stateController
    stateController.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    stateController.locationManager.requestWhenInUseAuthorization()
    stateController.locationManager.requestLocation()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.importeEtRechargeDonnees(forcerImportation: false)
  }
  
  // Appelle la recharge des données en s'assurant d'avoir des données à montrer
  func importeEtRechargeDonnees(forcerImportation: Bool) {
    // Les données sont déjà dans le view controller
    if !forcerImportation, self.donneesEnAffichage != nil {
      self.rechargeDonnees()
    }
    // Les données sont déjà disponibles dans le state controller
    else if !forcerImportation, let donneesEnAffichage = self.stateController?.donneDonneesPourLieuEnAffichage() {
      self.donneesEnAffichage = donneesEnAffichage
      self.rechargeDonnees()
    }
    // Les données ne sont pas disponibles et il faut les importer de manière asynchrone
    else {
      // Appeler la fonction du StateController, qui donnera les données du lieu actuel dans son completion handler
      self.stateController?.importeDonneesPourLieu("Montreal") { [weak self] (donneesPourLieu) in
        self?.donneesEnAffichage = donneesPourLieu
        DispatchQueue.main.async {
          self?.rechargeDonnees()
        }
      }
    }
  }
  
  func rechargeDonnees() {
    if let conditionsActuelles = self.conditionsActuelles {
      self.etiquetteTemperature.text = stateController?.donneChaineTemperatureConvertie(conditionsActuelles.donneTemperature())
      self.iconeCondition.image = conditionsActuelles.donneIcone()
      if let chaineCondition = conditionsActuelles.chaineCondition {
        self.etiquetteCondition.text = localiseChaineCondition(chaineCondition.lowercased())
      }
      if let pression = conditionsActuelles.pression {
        self.etiquettePression.text = stateController?.donneChainePressionConvertie(pression)
        if let tendancePression = conditionsActuelles.tendancePression {
          self.etiquettePression.text?.append(", \(tendancePression)")
        }
      }
      if let vitesseVent = conditionsActuelles.donneVitesseVent() {
        self.etiquetteVent.text = stateController?.donneChaineVitesseConvertie(vitesseVent)
      }
      if let vitesseRafales = conditionsActuelles.vitesseRafales {
        self.etiquetteRafales.isHidden = false
        self.etiquetteRafales.text = stateController?.donneChaineVitesseConvertie(vitesseRafales)
      } else {
        self.etiquetteRafales.isHidden = true
      }
      if let humidite = conditionsActuelles.humidite {
        self.etiquetteHumidite.text = "\(Int(humidite.rounded())) %"
      }
      if let pointDeRosee = conditionsActuelles.pointDeRosee {
        self.etiquettePointDeRosee.text = stateController?.donneChaineTemperatureConvertie(pointDeRosee)
      }
      // ceci n'existe pas dans les condiditons actuelles d'EC!
      if let indiceUV = conditionsActuelles.donneIndiceUV() {
        self.etiquetteIndiceUV.isHidden = false
        self.etiquetteIndiceUV.text = "\(indiceUV)"
      } else {
        self.etiquetteIndiceUV.isHidden = true
      }
      if let visibilite = conditionsActuelles.visibilite {
        self.etiquetteVisibilite.text = stateController?.donneChaineDistanceConvertie(visibilite)
      }
      self.etiquetteSource.text = "Source: \(conditionsActuelles.source.localizedString)"
      self.etiquetteHeureEmission.text = "Conditions observed at \(conditionsActuelles.donneChaineHeure())"
    }
  }
  
  //MARK: Actions
  
  @IBAction func reimporterDonnees(_ sender: Any) {
//    ImportateurPrevisions.global.importePrevisions()
    self.importeEtRechargeDonnees(forcerImportation: true)
  }
  
}

