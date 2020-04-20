//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct Stop: Codable, Identifiable {
  let id = UUID()
  let name: String?
  let publicId: String?
  let lat: Double
  let lng: Double
  let routesOnThisStop: [Route]
}
