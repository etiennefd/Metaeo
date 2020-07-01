//
//  Utilitaires.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-08.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

enum SourcePrevision: String {
  case environnementCanada, yrNo, meteomedia
}

enum PointCardinal: String {
  case N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW, SW, WSW, W, WNW, NW, NNW
}

enum TendancePression: String {
  case falling, rising, steady
}

func celsiusVersFahrenheit(_ celsius: Double) -> Double {
  return celsius * 1.8 + 32
}

func fahrenheitVersCelsius(_ fahrenheit: Double) -> Double {
  return (fahrenheit - 32) / 1.8
}
