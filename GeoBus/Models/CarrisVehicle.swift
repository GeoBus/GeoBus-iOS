//
//  CarrisVehicle.swift
//  GeoBus
//
//  Created by João on 07/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct CarrisVehicle: Codable, Identifiable, Equatable {
  var id = UUID()
  let busNumber: Int
  let vehiclePlate: String?
  let driverNumber: String?
  let routeNumber: String
  let lat: Double
  let lng: Double
  let lastGpsTime: String
  let angleInRadians: Double
  let lastStopOnVoyageId: String?
  let lastStopOnVoyageName: String?
  
}
