//
//  Utilitaires.swift
//  Metaeo
//
//  Created by Étienne Fortier-Dubois on 20-04-08.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import Foundation

enum TypePrevision {
  case actuel, jour, horaire
}

enum SourcePrevision: String {
  case environnementCanada = "Meteorological Service of Canada"
  case yrNo = "MET Norway"
  case NOAA = "National Weather Service"
  case openWeatherMap = "OpenWeatherMap"
  //case
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

func celsiusVersKelvin(_ celsius: Double) -> Double {
  return celsius + 273.15
}

func kelvinVersCelsius(_ kelvin: Double) -> Double {
  return kelvin - 273.15
}

func degresVersPointCardinal(_ degres: Double) -> PointCardinal? {
  switch degres {
  case 0..<11.25, 348.75..<360:
    return .N
  case 11.25..<33.75:
    return .NNE
  case 33.75..<56.25:
    return .NE
  case 56.25..<78.75:
    return .ENE
  case 78.75..<101.25:
    return .E
  case 101.25..<123.75:
    return .ESE
  case 123.75..<146.25:
    return .SE
  case 146.25..<168.75:
    return .SSE
  case 168.75..<191.25:
    return .S
  case 191.25..<213.75:
    return .SSW
  case 213.75..<236.25:
    return .SW
  case 236.25..<258.75:
    return .WSW
  case 258.75..<281.25:
    return .W
  case 281.25..<303.75:
    return .WNW
  case 303.75..<326.25:
    return .NW
  case 326.25..<348.75:
    return .NNW
  default:
    return nil
  }
}
