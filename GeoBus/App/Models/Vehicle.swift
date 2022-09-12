//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct Vehicle: Codable, Equatable, Identifiable {
   let busNumber: Int
   let plateNumber: String
   let routeNumber: String
   let kind: Kind
   let lat: Double
   let lng: Double
   let previousLatitude: Double?
   let previousLongitude: Double?
   let lastGpsTime: String
   let lastStopOnVoyageName: String

   var id: String {
      return String(describing: UUID())
   }
   
}
