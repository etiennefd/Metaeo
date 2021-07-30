//
//  RechercheLieuTableViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 2021-07-28.
//  Copyright © 2021 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit
import MapKit

class RechercheLieuTableViewController : UITableViewController {
  
  var stateController: StateController!
  
  var searchCompleter = MKLocalSearchCompleter()
  var searchResults = [MKLocalSearchCompletion]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.searchCompleter.delegate = self
    self.searchCompleter.resultTypes = .address
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return matchingItems.count
    return searchResults.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CelluleResultatRechercheLieu")!
    let searchResult = searchResults[indexPath.row]
    cell.textLabel?.text = searchResult.title
    print(searchResult.title)
    print(searchResult.subtitle)
    cell.detailTextLabel?.text = searchResult.subtitle
    return cell
  }
  
  // MARK: - Table view delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Désélectionne la ligne avec une animation
    tableView.deselectRow(at: indexPath, animated: true)
    
    // Résultat du SearchCompleter
    let completion = searchResults[indexPath.row]
    
    // Faire une requête à MKLocalSearch pour obtenir un Placemark
    let searchRequest = MKLocalSearch.Request(completion: completion)
    let search = MKLocalSearch(request: searchRequest)
    
    search.start { (response, error) in
      // Complétion de la requête :
      
      // Changer le lieu en affichage du StateController
      self.stateController.lieuEnAffichage = response?.mapItems[0].placemark
      
      // Fermer la vue et la vue présentatrice (SelectionLieuTableViewController)
      // Note : dimiss est overriden dans SelectionLieuTableViewController pour appeler une fonction de mise à jour dans les ViewControllers des conditions actuelles et des prévisions
      let presentViewController = self.presentingViewController
      self.dismiss(animated: true, completion: {
        presentViewController?.dismiss(animated: true, completion: nil)
      })
    }
  }
  
}

// Extension pour le protocole de search bar
extension RechercheLieuTableViewController : UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchBarText = searchController.searchBar.text else {
      return
    }
    self.searchCompleter.queryFragment = searchBarText
  }
  
}

// Extension pour le protocole d'autocomplete pour la search bar
extension RechercheLieuTableViewController : MKLocalSearchCompleterDelegate {
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    self.searchResults = completer.results.filter { result in
      // Les villes contiennent généralement une virgule dans le titre et aucun chiffre dans le titre ni le sous-titre
//      if !result.title.contains(",")
//          || result.title.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
//          || result.subtitle.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
//        return false
//      }
      return true
    }
    // Recharger la table une fois les search results trouvés
    self.tableView.reloadData()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    // handle error
  }
}
