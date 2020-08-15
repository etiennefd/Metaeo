//
//  TemperatureTableViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-08-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class TemperatureTableViewController: UITableViewController {
  
  //MARK: Properties
  var stateController: StateController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  // MARK: Table view data source
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = indexPath.section
    let numberOfRows = tableView.numberOfRows(inSection: section)
    for row in 0..<numberOfRows {
      if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
        if row == indexPath.row {
          cell.accessoryType = .checkmark
          if let identifier = cell.reuseIdentifier {
            switch identifier {
            case "CelluleUniteCelsius":
              stateController?.uniteTemperature = .celsius
            case "CelluleUniteFahrenheit":
              stateController?.uniteTemperature = .fahrenheit
            case "CelluleUniteKelvin":
              stateController?.uniteTemperature = .kelvin
            default: break
            }
          }
        } else {
          cell.accessoryType = .none
        }
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    switch (stateController?.uniteTemperature, cell.reuseIdentifier) {
    case (.celsius, "CelluleUniteCelsius"),
         (.fahrenheit, "CelluleUniteFahrenheit"),
         (.kelvin, "CelluleUniteKelvin"):
      cell.accessoryType = .checkmark
    default:
      cell.accessoryType = .none
    }
  }
  
  //    override func numberOfSections(in tableView: UITableView) -> Int {
  //        // #warning Incomplete implementation, return the number of sections
  //        return 0
  //    }
  
  //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  //        // #warning Incomplete implementation, return the number of rows
  //        return 0
  //    }
  
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
  
}
