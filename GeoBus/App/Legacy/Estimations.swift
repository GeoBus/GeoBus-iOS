//
//  Estimations.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation


/* MARK: - Estimation */

// Data model adjusted for the app.

struct Estimation: Codable, Identifiable, Equatable {
   let routeNumber: String
   let destination: String
   let publicId: String
   let busNumber: String?
   let eta: String

   var id: String {
      return UUID().uuidString
   }

}
