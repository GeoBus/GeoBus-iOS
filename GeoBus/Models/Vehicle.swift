//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct Vehicle: Codable, Identifiable {
  let id = UUID()
  let routeNumber: String
  let busNumber: Int
  let direction: String
  let lat: Double
  let lng: Double
}
