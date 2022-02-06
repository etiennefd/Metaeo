//
//  ConditionsActuellesViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit
import MapKit

class ConditionsActuellesViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
  
  //MARK: Properties
  //var conditionsActuelles: Prevision!
  var stateController: StateController!
  
  var lieuEnAffichage: CLPlacemark? // seulement pour savoir s'il a changé; on préfère utiliser directement celui dans StateController
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
  //@IBOutlet weak var etiquetteIndiceUV: UILabel!
  @IBOutlet weak var etiquetteVisibilite: UILabel!
  @IBOutlet weak var etiquetteSource: UILabel!
  @IBOutlet weak var etiquetteHeureObservation: UILabel!
  @IBOutlet weak var etiquetteLieuObservation: UILabel!
  @IBOutlet weak var itemNavigationLieu: UINavigationItem!
  @IBOutlet weak var etiquetteVille: UILabel!
  @IBOutlet weak var etiquetteRegionPays: UILabel!
  
  var resultSearchController: UISearchController? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    //self.importeEtRechargeDonnees(forcerImportation: false)
    
    // Location manager
    stateController.locationManager.delegate = stateController
    stateController.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    stateController.locationManager.requestWhenInUseAuthorization()
    stateController.locationManager.requestLocation()
    
    // Au tout début de l'utilisation de l'app, on va chercher le lieu de l'utilisateur
    stateController.obtenirLieuDepuisLieuUtilisateur(completion: {
      self.metAJourLieu()
    })
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if self.stateController.lieuEnAffichage != self.lieuEnAffichage {
      self.metAJourLieu()
    }
    //self.importeEtRechargeDonnees(forcerImportation: false)
  }
  
  // MARK: Chargement des données
  
  // Change le lieu, affiche le lieu, et réimporte les données
  func metAJourLieu() {
    self.lieuEnAffichage = self.stateController.lieuEnAffichage
    guard let lieu = self.lieuEnAffichage else {
      return
    }
    //self.itemNavigationLieu.title = lieu.name ?? NSLocalizedString("Unknown locality", comment: "")
    self.etiquetteVille.text = lieu.locality ?? NSLocalizedString("Unknown locality", comment: "")
    // à déterminer : utiliser le name ou la locality?
    let region = (lieu.administrativeArea != nil) ? "\(lieu.administrativeArea!), " : ""
    let regionPays = region + (lieu.country ?? "")
    self.etiquetteRegionPays.text = regionPays
    self.importeEtRechargeDonnees(forcerImportation: false)
  }
  
  // Appelle la recharge des données en s'assurant d'avoir des données à montrer
  func importeEtRechargeDonnees(forcerImportation: Bool) {

    // Les données sont déjà dans le view controller et le lieu n'a pas changé
    if !forcerImportation, self.donneesEnAffichage != nil, self.donneesEnAffichage!.lieu == self.lieuEnAffichage {
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
      guard let lieu = self.stateController.lieuEnAffichage else {
        return
      }
      print("\(stateController.lieuUtilisateur.coordinate.latitude), \(stateController.lieuUtilisateur.coordinate.longitude)")
      print("\(lieu)")
      
      self.stateController?.importeDonneesPourLieu(lieu) { [weak self] (donneesPourLieu) in
        self?.donneesEnAffichage = donneesPourLieu
        DispatchQueue.main.async {
          self?.rechargeDonnees()
        }
      }
    }
  }
  
  // Place les données dans les éléments d'interface
  func rechargeDonnees() {
    if let conditionsActuelles = self.conditionsActuelles {
      self.etiquetteTemperature.text = stateController?.donneChaineTemperatureConvertie(conditionsActuelles.donneTemperature())
      self.iconeCondition.image = conditionsActuelles.donneIcone()
      if let chaineCondition = conditionsActuelles.chaineCondition {
        self.etiquetteCondition.text = localiseChaineCondition(chaineCondition.lowercased())
      } else {
        self.etiquetteCondition.text = NSLocalizedString("Condition not observed", comment: "")
      }
      if let pression = conditionsActuelles.pression {
        self.etiquettePression.text = stateController?.donneChainePressionConvertie(pression)
        if let tendancePression = conditionsActuelles.tendancePression {
          self.etiquettePression.text?.append(" \(tendancePression.fleche)")
        }
      }
      if let vitesseVent = conditionsActuelles.donneVitesseVent() {
        self.etiquetteVent.text = stateController?.donneChaineVitesseConvertie(vitesseVent)
        if let directionVent = conditionsActuelles.directionVent {
          self.etiquetteVent.text?.append(" \(directionVent.localizedString)")
        }
      }
      if let vitesseRafales = conditionsActuelles.vitesseRafales {
        //self.etiquetteRafales.isHidden = false
        self.etiquetteRafales.text = stateController?.donneChaineVitesseConvertie(vitesseRafales)
      } else {
        //self.etiquetteRafales.isHidden = true
        self.etiquetteRafales.text = NSLocalizedString("no", comment: "")
      }
      if let humidite = conditionsActuelles.humidite {
        self.etiquetteHumidite.text = "\(Int(humidite.rounded())) %"
      }
      if let pointDeRosee = conditionsActuelles.pointDeRosee {
        self.etiquettePointDeRosee.text = stateController?.donneChaineTemperatureConvertie(pointDeRosee)
      }
      // ceci n'existe pas dans les condiditons actuelles d'EC!
//      if let indiceUV = conditionsActuelles.donneIndiceUV() {
//        self.etiquetteIndiceUV.isHidden = false
//        self.etiquetteIndiceUV.text = "\(indiceUV)"
//      } else {
//        self.etiquetteIndiceUV.isHidden = true
//      }
      if let visibilite = conditionsActuelles.visibilite {
        self.etiquetteVisibilite.text = stateController?.donneChaineDistanceConvertie(visibilite)
      }
      // À faire : localiser "Source", "Conditions observed at", etc.
      
      self.etiquetteHeureObservation.text = "\(NSLocalizedString("Last updated at:", comment: "")) \(conditionsActuelles.donneChaineHeure())"
      self.etiquetteLieuObservation.text = "\(NSLocalizedString("Observed at:", comment: "")) \(conditionsActuelles.lieu ?? NSLocalizedString("Unknown location", comment: ""))"
      self.etiquetteSource.text = "\(NSLocalizedString("Source:", comment: "")) \(conditionsActuelles.source.localizedString)"
    }
  }
  
  //MARK: Actions
  
  @IBAction func reimporterDonnees(_ sender: Any) {
//    ImportateurPrevisions.global.importePrevisions()
    self.importeEtRechargeDonnees(forcerImportation: true)
  }
  
  // MARK: Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    switch(segue.identifier ?? "") {
    
    case "MontrerSelectionLieu":
      guard let navigationController = segue.destination as? UINavigationController,
            let selectionLieuTableViewController = navigationController.viewControllers.first as? SelectionLieuTableViewController else {
        fatalError("Unexpected destination: \(segue.destination)")
      }
      selectionLieuTableViewController.stateController = self.stateController
      selectionLieuTableViewController.presentationController?.delegate = self;
      
    default:
      break
//      fatalError("Unexpected segue identifier: \(segue.identifier ?? "")")
    }
  }
  
  // Only called when the sheet is dismissed by DRAGGING or through the overriden dismiss() function
  // Voir : https://stackoverflow.com/questions/56568967/detecting-sheet-was-dismissed-on-ios-13
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
  {
    if self.stateController.lieuEnAffichage != self.lieuEnAffichage {
      self.metAJourLieu()
    }
  }
}

