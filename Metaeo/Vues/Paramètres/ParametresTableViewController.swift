//
//  ParametresTableViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-07-12.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class ParametresTableViewController: UITableViewController {
  
  //MARK: Properties
  var stateController: StateController?

  @IBOutlet weak var etiquetteUniteTemperature: UILabel!
  @IBOutlet weak var etiquetteUniteDistance: UILabel!
  @IBOutlet weak var etiquetteUniteVitesseVent: UILabel!
  @IBOutlet weak var etiquetteUnitePression: UILabel!
  
  //MARK: Initialisation
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  // MARK: Table view data source
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    switch cell.reuseIdentifier {
    case "CelluleUniteTemperature":
      cell.detailTextLabel?.text = self.stateController?.uniteTemperature.symbol
    case "CelluleUniteDistance":
      cell.detailTextLabel?.text = self.stateController?.uniteDistance.symbol
    case "CelluleUniteVitesseVent":
      cell.detailTextLabel?.text = self.stateController?.uniteVitesseVent.symbol
    case "CelluleUnitePression":
      cell.detailTextLabel?.text = self.stateController?.unitePression.symbol
    case "CelluleModeSombre":
      cell.detailTextLabel?.text = self.stateController?.modeSombre.chaineModeSombre
    default: break
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
//  override func numberOfSections(in tableView: UITableView) -> Int {
//    // #warning Incomplete implementation, return the number of sections
//    return 0
//  }
//  
//  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    // #warning Incomplete implementation, return the number of rows
//    return 0
//  }
  
  /*
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
   
   // Configure the cell...
   
   return cell
   }
   */
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
   // MARK: Navigation
   
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    super.prepare(for: segue, sender: sender)
    if let selectionUniteTableViewController = segue.destination as? SelectionUniteTableViewController {
      selectionUniteTableViewController.stateController = self.stateController
    }
    else if let selectionAffichageTableViewController = segue.destination as? SelectionAffichageTableViewController {
      selectionAffichageTableViewController.stateController = self.stateController
    }
  }
  
//  private func metAJourDetailDeCellule(_ cell: UITableViewCell) {
//    switch cell.reuseIdentifier {
//    case "CelluleUniteTemperature":
//      cell.detailTextLabel?.text = self.stateController?.uniteTemperature.symbol
//    default: break
//    }
//  }
  
}
