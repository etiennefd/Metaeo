//
//  MetaeoTests.swift
//  MetaeoTests
//
//  Created by Étienne Fortier-Dubois on 20-04-02.
//  Copyright © 2020 Étienne Fortier-Dubois. All rights reserved.
//

import XCTest
@testable import Metaeo

class MetaeoTests: XCTestCase {
  
  var secondViewCtrl: SecondViewController = SecondViewController()
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
  func testRandomShit() {
    let doubleFromString = Double("")
    XCTAssert(doubleFromString == nil)
  }
  
  func testFetchPrevision() {
    //let url = URL(string: "https://www.yr.no/place/Canada/Quebec/Montreal/forecast.xml")!
    let url = URL(string: "https://dd.meteo.gc.ca/citypage_weather/xml/QC/s0000635_e.xml")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data else {
        print(error ?? "Erreur inconnue")
        return
      }
      print(String(data: data, encoding: .utf8)!)
      // Parser le xml
      let parser = XMLParser(data: data)
      parser.delegate = self.secondViewCtrl
      if parser.parse() {
        let conditionsActuelles = self.secondViewCtrl.conditionsActuelles
        print(conditionsActuelles ?? "")
      }
    }
    task.resume()
  }
  
}
