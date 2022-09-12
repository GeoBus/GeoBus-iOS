//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

struct Estimation: Codable, Identifiable, Equatable {
   let id = UUID()
   let routeNumber: String
   let destination: String
   let time: String // Expected time of arrival
   let publicId: String
}
