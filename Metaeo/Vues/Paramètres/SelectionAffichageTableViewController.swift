//
//  SelectionUniteTableViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-08-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class SelectionAffichageTableViewController: UITableViewController {
  
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
            case "CelluleModeSombreAuto":
              stateController?.changeModeSombre(.unspecified)
//              stateController?.modeSombre = .unspecified
            case "CelluleModeSombreOn":
              stateController?.changeModeSombre(.dark)
//              stateController?.modeSombre = .dark
            case "CelluleModeSombreOff":
              stateController?.changeModeSombre(.light)
//              stateController?.modeSombre = .light
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
    if let modeSombre = stateController?.modeSombre {
      switch (modeSombre, cell.reuseIdentifier) {
      case (.unspecified, "CelluleModeSombreAuto"),
           (.dark, "CelluleModeSombreOn"),
           (.light, "CelluleModeSombreOff"):
        cell.accessoryType = .checkmark
        return
      default: break
      }
    }
    cell.accessoryType = .none
  }
  
}
