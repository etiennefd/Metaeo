//
//  SelectionUniteTableViewController.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-08-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import UIKit

class SelectionUniteTableViewController: UITableViewController {
  
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
              stateController?.doitRechargerListePrevision = true
            case "CelluleUniteFahrenheit":
              stateController?.uniteTemperature = .fahrenheit
              stateController?.doitRechargerListePrevision = true
            case "CelluleUniteKelvin":
              stateController?.uniteTemperature = .kelvin
              stateController?.doitRechargerListePrevision = true
            case "CelluleUniteKm":
              stateController?.uniteDistance = .kilometers
            case "CelluleUniteMi":
              stateController?.uniteDistance = .miles
            case "CelluleUniteMs":
              stateController?.uniteVitesseVent = .metersPerSecond
            case "CelluleUniteKmh":
              stateController?.uniteVitesseVent = .kilometersPerHour
            case "CelluleUniteMph":
              stateController?.uniteVitesseVent = .milesPerHour
            case "CelluleUniteFts":
              stateController?.uniteVitesseVent = .feetPerSecond
            case "CelluleUniteKnots":
              stateController?.uniteVitesseVent = .knots
            case "CelluleUniteBeaufort":
              stateController?.uniteVitesseVent = .beaufort
            case "CelluleUniteKPa":
              stateController?.unitePression = .kilopascals
            case "CelluleUniteHPa":
              stateController?.unitePression = .hectopascals
            case "CelluleUniteMillibar":
              stateController?.unitePression = .millibars
            case "CelluleUniteMmHg":
              stateController?.unitePression = .millimetersOfMercury
            case "CelluleUniteInHg":
              stateController?.unitePression = .inchesOfMercury
            case "CelluleUnitePsi":
              stateController?.unitePression = .poundsForcePerSquareInch
            case "CelluleUniteAtm":
              stateController?.unitePression = .atmosphere
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
    if let uniteTemperature = stateController?.uniteTemperature {
      switch (uniteTemperature, cell.reuseIdentifier) {
      case (.celsius, "CelluleUniteCelsius"),
           (.fahrenheit, "CelluleUniteFahrenheit"),
           (.kelvin, "CelluleUniteKelvin"):
        cell.accessoryType = .checkmark
        return
      default: break
      }
    }
    if let uniteDistance = stateController?.uniteDistance {
      switch (uniteDistance, cell.reuseIdentifier) {
      case (.kilometers, "CelluleUniteKm"),
           (.miles, "CelluleUniteMi"):
        cell.accessoryType = .checkmark
        return
      default: break
      }
    }
    if let uniteVitesseVent = stateController?.uniteVitesseVent {
      switch (uniteVitesseVent, cell.reuseIdentifier) {
      case (.metersPerSecond, "CelluleUniteMs"),
           (.kilometersPerHour, "CelluleUniteKmh"),
           (.milesPerHour, "CelluleUniteMph"),
           (.feetPerSecond, "CelluleUniteFts"),
           (.knots, "CelluleUniteKnots"),
           (.beaufort, "CelluleUniteBeaufort"):
        cell.accessoryType = .checkmark
        return
      default: break
      }
    }
    if let unitePression = stateController?.unitePression {
      switch (unitePression, cell.reuseIdentifier) {
      case (.kilopascals, "CelluleUniteKPa"),
           (.hectopascals, "CelluleUniteHPa"),
           (.millibars, "CelluleUniteMillibar"),
           (.millimetersOfMercury, "CelluleUniteMmHg"),
           (.inchesOfMercury, "CelluleUniteInHg"),
           (.poundsForcePerSquareInch, "CelluleUnitePsi"),
           (.atmosphere, "CelluleUniteAtm"):
        cell.accessoryType = .checkmark
        return
      default: break
      }
    }
    cell.accessoryType = .none
  }
  
}
