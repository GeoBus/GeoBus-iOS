//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation
import MapKit

struct Vehicle: Codable, Identifiable, Equatable {
  let id = UUID()
  let busNumber: Int
  let vehiclePlate: String?
  let driverNumber: String?
  let routeNumber: String?
  let lat: Double
  let lng: Double
  let angleInRadians: Double
  let lastStopOnVoyageId: String?
  let lastStopOnVoyageName: String?
}
