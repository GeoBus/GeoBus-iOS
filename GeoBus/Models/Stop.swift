//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct Stop: Codable, Identifiable, Equatable {
  let id = UUID()
  let orderInRoute: Int
  let publicId: String
  let name: String
  let lat: Double
  let lng: Double
}


