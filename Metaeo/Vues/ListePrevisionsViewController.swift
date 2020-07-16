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
  
  var montrerPrevisionsParHeure = false // pour alterner entre prévisions par jour et prévisions horaires
  
  var periodeEnSelection: Date!
  var sourceEnSelection: SourcePrevision!
  var previsionsStockees: [SourcePrevision : [Date : Prevision]] {
    return montrerPrevisionsParHeure ?
      ImportateurPrevisions.global.donneesEnAffichage.previsionsParHeure :
      ImportateurPrevisions.global.donneesEnAffichage.previsionsParJour
  }
  var previsionsParSourceAffichees = [Prevision]() // dans la table view
  var previsionsParPeriodeAffichees = [Prevision]() // dans la collection view
  @IBOutlet weak var listePrevisionsTableView: UITableView!
  @IBOutlet weak var periodesCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    // Bouton d'édition de la table
    self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    // Tape longue pour sélectionner la source
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
    //longPressGesture.minimumPressDuration = 0.5
    self.listePrevisionsTableView.addGestureRecognizer(longPressGesture)
    
    // Charger les données du CollectionView et du TableView
    self.rechargeDonnees()
  }
  
  func rechargeDonnees() {
//    let ffff = self.previsionsStockees
    
    // choisir la 1re cellule dans chaque vue
//    self.periodeEnSelection = self.previsionsStockees.values.first?.keys.sorted().first
    self.periodeEnSelection = self.previsionsStockees[.environnementCanada]?.keys.sorted().first
    self.sourceEnSelection = self.previsionsStockees.keys.first
    
    self.rechargeDonneesTableView()
    self.rechargeDonneesCollectionView()
    
    //print("avant selectItem!!!")
    if self.previsionsParPeriodeAffichees.count > 0 {
      self.periodesCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
    }
    //print("après selectItem!!!")
  }
  
  func rechargeDonneesTableView() {
//    let ffff = self.previsionsStockees
    
    previsionsParSourceAffichees.removeAll()
    self.sourceEnSelection = self.previsionsStockees.keys.first
    
    for (_, previsionsParPeriode) in self.previsionsStockees {
      // remplir le tableau des prévisions par source selon la période choisie (table view)
      if let previsionPourPeriodeEnSelection = previsionsParPeriode[self.periodeEnSelection] {
        previsionsParSourceAffichees.append(previsionPourPeriodeEnSelection)
      }
    }
    self.listePrevisionsTableView.reloadData()
  }
  
  func rechargeDonneesCollectionView() {
    previsionsParPeriodeAffichees.removeAll()
    
    // temporaire (à remplacer par une sélection de l'utilisateur, et décider quoi utiliser par défaut) :
    self.periodeEnSelection = self.previsionsStockees.values.first?.first?.value.donneHeure()
    
    // remplir le tableau des prévisions à afficher
    for (source, previsionsParPeriode) in self.previsionsStockees {
      // remplir le tableau des prévisions par période selon la source choisie (collection view)
      if source == self.sourceEnSelection {
        for (date, prevision) in previsionsParPeriode {
          // éviter d'afficher :
          // prévisions horaires antérieures au moment présent
          // prévisions horaires postérieures à 24h dans le futur
          // prévisions par jour postérieures à 6 jours dans le futur
          let maintenant = Date()
          guard let dans24h = Calendar.current.date(byAdding: .day, value: 1, to: maintenant),
            let dans6Jours = Calendar.current.date(byAdding: .day, value: 6, to: maintenant) else {
              continue
          }
          if (prevision.type == .horaire && (date < maintenant || date > dans24h))
            || (prevision.type == .jour && date > dans6Jours) {
            continue
          }
          previsionsParPeriodeAffichees.append(prevision)
        }
      }
    }
    previsionsParPeriodeAffichees.sort(by: { $0.heureDebut < $1.heureDebut })
    
    // recharger les données
    self.periodesCollectionView.reloadData()
  }
  
  // Pour utiliser le bouton Edit/Done
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    listePrevisionsTableView.setEditing(editing, animated: animated)
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
    
    cellule.etiquetteSource.text = prevision.source.rawValue
    cellule.etiquetteTemperature.text = prevision.donneChaineTemperature()
    cellule.vueIconeMeteo.image = prevision.donneIcone()
    cellule.etiquetteCondition.text = prevision.condition?.rawValue
    
    return cellule
  }
  
  // Réordonner

  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let itemToMove = previsionsParSourceAffichees[sourceIndexPath.row]
    previsionsParSourceAffichees.remove(at: sourceIndexPath.row)
    previsionsParSourceAffichees.insert(itemToMove, at: destinationIndexPath.row)
  }
  
  // enlève le bouton supprimer pendant l'édition de la table
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .none
  }
  
  // enlève l'indentation pendant l'édition de la table
  func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
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

//    if prevision.type == .horaire {
//      cellule.etiquettePeriode.text = dateFormatterPrevisionHoraire.string(from: prevision.heureDebut)
//    } else {
//      cellule.etiquettePeriode.text = prevision.chainePeriode
//    }
    cellule.etiquettePeriode.text = prevision.donneChainePeriode()
    cellule.etiquetteTemperature.text = prevision.donneChaineTemperature()
    cellule.vueIconeMeteo.image = prevision.donneIcone()
    
    return cellule
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    let index = indexPath.row
    let previsionSelectionnee = self.previsionsParPeriodeAffichees[index]
    self.periodeEnSelection = previsionSelectionnee.heureDebut
    self.rechargeDonneesTableView()
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    switch(segue.identifier ?? "") {
    case "MontrerDetailsPrevision":
      guard let detailsPrevisionViewController = segue.destination as? DetailsPrevisionViewController else {
        fatalError("Unexpected destination: \(segue.destination)")
      }
      guard let celluleSelectionnee = sender as? PrevisionSourceTableViewCell else {
        fatalError("Unexpected sender : \(sender ?? "")")
      }
      guard let indexPath = self.listePrevisionsTableView.indexPath(for: celluleSelectionnee) else {
        fatalError("The selected cell is not being displayed by the table")
      }
      let previsionSelectionnee = self.previsionsParSourceAffichees[indexPath.row]
      detailsPrevisionViewController.previsionAffichee = previsionSelectionnee
    default:
      fatalError("Unexpected segue identifier: \(segue.identifier ?? "")")
    }
  }
  
  //MARK: Actions
  
  @IBAction func changerTypePeriode(_ sender: Any) {
    let segmentedControl = sender as? UISegmentedControl
    switch segmentedControl?.selectedSegmentIndex {
    case 0:
      montrerPrevisionsParHeure = false
    case 1:
      montrerPrevisionsParHeure = true
    default:
      break
    }
    self.rechargeDonnees()
  }
  
  //MARK: Gestures

  // Tape longue pour sélectionner la source à utiliser dans les prévisions du CollectionView
  @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
    if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
      let touchPoint = longPressGestureRecognizer.location(in: self.listePrevisionsTableView)
      if let indexPath = self.listePrevisionsTableView.indexPathForRow(at: touchPoint) {
        self.listePrevisionsTableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        let prevision = previsionsParSourceAffichees[indexPath.row]
        self.sourceEnSelection = prevision.source
        self.rechargeDonneesCollectionView()
      }
    }
  }
  
  
}

