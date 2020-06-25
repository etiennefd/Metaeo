//
//  ListePrevisionsViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class ListePrevisionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

  //MARK: Properties
  var montrerPrevisionsParHeure = false
  var periodeEnSelection: String! // plus tard : Date?
  var sourceEnSelection: SourcePrevision!
  var previsionsParSourceAffichees = [Prevision]() // dans la table view
  var previsionsParPeriodeAffichees = [Prevision]() // dans la collection view
  @IBOutlet weak var listePrevisionsTableView: UITableView!
  @IBOutlet weak var periodesCollectionView: UICollectionView!
  @IBOutlet weak var boutonChangerTypePeriode: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    rechargeDonnees()
  }
  
  func rechargeDonnees() {
    let previsions = montrerPrevisionsParHeure ?
      ImportateurPrevisions.global.previsionsParHeure :
      ImportateurPrevisions.global.previsionsParJour
    
    // temporaire (à remplacer par une sélection de l'utilisateur, et décider quoi utiliser par défaut) :
    self.periodeEnSelection = previsions.values.first?.first?.value.periode
    self.sourceEnSelection = previsions.keys.first
    
    // remplir le tableau des prévisions à afficher
    for (source, previsionsParPeriode) in previsions {
      // remplir le tableau des prévisions par source selon la période choisie (table view)
      if let previsionPourPeriodeEnSelection = previsionsParPeriode[periodeEnSelection] {
        previsionsParSourceAffichees.append(previsionPourPeriodeEnSelection)
      }
      // remplir le tableau des prévisions par période selon la source choisie (collection view)
      if source == self.sourceEnSelection {
        for (_, prevision) in previsionsParPeriode {
          previsionsParPeriodeAffichees.append(prevision)
        }
      }
    }
    
    // recharger les données
    self.listePrevisionsTableView.reloadData()
    self.periodesCollectionView.reloadData()
  }
  
  //MARK: UITableViewDataSource
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1 // plus tard, peut-être avoir différentes sections? Ex. : agences gouv., modèles météo, API payantes, API non disponibles
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.previsionsParSourceAffichees.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Table view cells are reused and should be dequeued using a cell identifier.
    let identifiantCellule = "PrevisionSourceTableViewCell"
    guard let cellule = tableView.dequeueReusableCell(withIdentifier: identifiantCellule, for: indexPath) as? PrevisionSourceTableViewCell else {
      fatalError("The dequeued cell is not an instance of PrevisionSourceTableViewCell.")
    }
    
    let prevision = previsionsParSourceAffichees[indexPath.row]
    
    cellule.etiquetteSource.text = prevision.source
    cellule.etiquetteTemperature.text = prevision.chaineTemperature()
    //cell.vueIconeMeteo.image = ?
    
    return cellule
  }
  
  //MARK: UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.previsionsParPeriodeAffichees.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let identifiantCellule = "PrevisionPeriodeCollectionViewCell"
    guard let cellule = collectionView.dequeueReusableCell(withReuseIdentifier: identifiantCellule, for: indexPath) as? PrevisionPeriodeCollectionViewCell else {
        fatalError("The dequeued cell is not an instance of PrevisionPeriodeCollectionViewCell.")
    }
    
    let prevision = previsionsParPeriodeAffichees[indexPath.row]
    
    cellule.etiquettePeriode.text = prevision.periode
    cellule.etiquetteTemperature.text = prevision.chaineTemperature()
    //cellule.vueIconeMeteo.image = ?
    //cellule.backgroundColor = .black
    
    return cellule
  }
  
  //MARK: Actions
  
  @IBAction func changerTypePeriode(_ sender: Any) {
    montrerPrevisionsParHeure = !montrerPrevisionsParHeure
    let bouton = sender as? UIButton
    if montrerPrevisionsParHeure {
      bouton?.setTitle("Par heure", for: .normal)
    } else {
      bouton?.setTitle("Par jour", for: .normal)
    }
    self.rechargeDonnees()
  }
  
  
}

