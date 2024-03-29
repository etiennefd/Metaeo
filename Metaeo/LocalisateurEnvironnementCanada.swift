//
//  LocalisateurEnvironnementCanada.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 2021-07-30.
//  Copyright © 2021 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

struct StationEnvironnementCanada {
  var code: String
  var nom: String
  var province: String // code à deux lettres, ex. "QC"
  var latitude: Double
  var longitude: Double
}

class LocalisateurEnvironnementCanada {
  
  let codesDeProvinceValides = ["AB","BC","MB","NB","NL","NS","NT","NU","ON","QC","SK","YU"]
  let urlStations = "https://dd.weather.gc.ca/citypage_weather/docs/site_list_en.csv"
  
  var stations: [StationEnvironnementCanada] = []
  
  // Concurrency
  let dispatchGroup = DispatchGroup()
  
  private func obtenirStations() {
    let tache = URLSession.shared.dataTask(with: URL(string: urlStations)!) { data, response, error in
      guard let data = data, error == nil else {
        print(error ?? "Erreur avec l'url des stations d'EC")
        return
      }
      // Parser le CSV
      var rows = String(decoding: data, as: UTF8.self).components(separatedBy: "\n")
      rows.removeFirst() // "Site Names,,,,"
      rows.removeFirst() // "Codes,English Names,Province Codes,Latitude,Longitude"
      for row in rows {
        //print(row)
        let columns = row.components(separatedBy: ",")
        if columns.count != 5 {
          continue
        }
        let code = columns[0]
        let nom = columns[1]
        let province = columns[2]
        if !self.codesDeProvinceValides.contains(province) {
          continue
        }
        let latitude = Double(columns[3].replacingOccurrences(of: "N", with: ""))!
        let longitude = -Double(columns[4].replacingOccurrences(of: "W", with: ""))! // négatif parce que c'est W (vrai pour tous les lieux au Canada)
        let station = StationEnvironnementCanada(code: code, nom: nom, province: province, latitude: latitude, longitude: longitude)
        self.stations.append(station)
      }
      self.dispatchGroup.leave()
    }
    tache.resume()
  }
  
  // TODO: aussi obtenir la 2e station et choisir celle-ci si jamais la 1re a "Condition not observed"
  private func trouverStationPlusPresDe(latitude: Double, longitude: Double) -> StationEnvironnementCanada {
    // si on n'a pas encore chargé les données de stations, il faut le faire avant d'essayer de les utiliser
    if stations.count == 0 {
      self.dispatchGroup.enter()
      DispatchQueue.global(qos: .default).async {
        self.obtenirStations() // le dispatchGroup.leave est à la fin de l'appel asynchrone pour obtenir les données de stations
      }
      self.dispatchGroup.wait()
    }
    // au cas où il y a eu une erreur dans l'importation des stations (implémentation pas idéale mais bon ça va empêcher un crash)
    if stations.count == 0 {
      print("Les stations météo n'ont pas pu être chargées. Par défaut on utilise donc Montréal.")
      return StationEnvironnementCanada(code: "s0000635", nom: "Montréal", province: "QC", latitude: 0.0, longitude: 0.0)
    }
    var stationLaPlusPres = stations[0]
    var meilleureDistance = calculerDistanceEntre((latitude, longitude), et: (stations[0].latitude, stations[0].longitude))
    for station in stations {
      // Calculer la distance
      let distance = calculerDistanceEntre((latitude, longitude), et: (station.latitude, station.longitude))
      if distance < meilleureDistance {
        stationLaPlusPres = station
        meilleureDistance = distance
      }
    }
    return stationLaPlusPres
  }
  
  private func calculerDistanceEntre(_ coord1: (latitude: Double, longitude: Double), et coord2: (latitude: Double, longitude: Double)) -> Double {
    let differenceLatitude = coord1.latitude - coord2.latitude
    let differenceLongitude = coord1.longitude - coord2.longitude
    return sqrt(pow(differenceLatitude, 2.0) + pow(differenceLongitude, 2.0))
  }
  
  func obtenirURLPour(latitude: Double, longitude: Double) -> String {
    let station = trouverStationPlusPresDe(latitude: latitude, longitude: longitude)
    return "https://dd.meteo.gc.ca/citypage_weather/xml/\(station.province)/\(station.code)_e.xml"
  }
}
