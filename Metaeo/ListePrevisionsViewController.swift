//
//  ListePrevisionsViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class ListePrevisionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  //MARK: Properties
  var montrerPrevisionsParHeure = false
  var periodeEnSelection: String! // plus tard : Date?
  var previsionsAffichees = [Prevision]()
  @IBOutlet weak var listePrevisionsTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    rechargeDonnees()
  }
  
  func rechargeDonnees() {
    let previsions = montrerPrevisionsParHeure ?
      ImportateurPrevisions.global.previsionsParHeure :
      ImportateurPrevisions.global.previsionsParPeriode
    
    // temporaire : (à remplacer par une sélection de l'utilisateur, et décider quoi utiliser par défaut)
    self.periodeEnSelection = previsions.values.first?.first?.value.periode
    
    // remplir le tableau des prévisions à afficher
    for (_, previsionsParPeriode) in previsions {
      // pour utiliser la source, remplacer "_" par "source"
      if let previsionPourPeriodeEnSelection = previsionsParPeriode[periodeEnSelection] {
        previsionsAffichees.append(previsionPourPeriodeEnSelection)
      }
    }
    
    // recharger les données
    self.listePrevisionsTableView.reloadData()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1 // plus tard, peut-être avoir différentes sections? Ex. : agences gouv., modèles météo, API payantes, API non disponibles
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.previsionsAffichees.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Table view cells are reused and should be dequeued using a cell identifier.
    let cellIdentifier = "PrevisionSourceTableViewCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PrevisionSourceTableViewCell else {
      fatalError("The dequeued cell is not an instance of PrevisionSourceTableViewCell.")
    }
    
    let prevision = previsionsAffichees[indexPath.row]
    
    cell.etiquetteSource.text = prevision.source
    cell.etiquetteTemperature.text = prevision.chaineTemperature()
    //cell.vueIconeMeteo.image = ?
    
    return cell
  }
  
  
}

