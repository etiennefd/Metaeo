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
  var dateFormatterPrevisionHoraire = DateFormatter()
  
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
    
    dateFormatterPrevisionHoraire.dateStyle = .none
    dateFormatterPrevisionHoraire.timeStyle = .short
    dateFormatterPrevisionHoraire.locale = Locale.current // à faire : s'assurer que l'heure affichée corresponde au fuseau horaire du lieu, pas de l'utilisateur
    
    self.rechargeDonnees()
  }
  
  func rechargeDonnees() {
    // choisir la 1re cellule dans chaque vue
    let ffff = self.previsionsStockees
//    self.periodeEnSelection = self.previsionsStockees.values.first?.keys.sorted().first
    self.periodeEnSelection = self.previsionsStockees[.environnementCanada]?.keys.sorted().first
    self.sourceEnSelection = self.previsionsStockees.keys.first
    
    self.rechargeDonneesTableView()
    self.rechargeDonneesCollectionView()
    
    print("avant selectItem!!!")
    if self.previsionsParPeriodeAffichees.count > 0 {
      self.periodesCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
    }
    print("après selectItem!!!")
  }
  
  func rechargeDonneesTableView() {
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
          // Éviter d'afficher
          if prevision.type == .horaire, date < Date() {
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
    cellule.etiquetteTemperature.text = prevision.chaineTemperature()
    cellule.vueIconeMeteo.image = prevision.donneIcone()
    cellule.etiquetteCondition.text = prevision.condition?.rawValue
    
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

    if prevision.type == .horaire {
      cellule.etiquettePeriode.text = dateFormatterPrevisionHoraire.string(from: prevision.heureDebut)
    } else {
      cellule.etiquettePeriode.text = prevision.chainePeriode
    }
    cellule.etiquetteTemperature.text = prevision.chaineTemperature()
    cellule.vueIconeMeteo.image = prevision.donneIcone()
    //cellule.backgroundColor = .black
    
    return cellule
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    let index = indexPath.row
    let previsionSelectionnee = self.previsionsParPeriodeAffichees[index]
    self.periodeEnSelection = previsionSelectionnee.heureDebut
    self.rechargeDonneesTableView()
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
  
  
}

