//
//  Estimations.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

/* MARK: - API Estimation */

// Data model as provided by the API.
// Schema is available at https://joaodcp.github.io/Carris-API

struct APIEstimation: Decodable {
   let routeNumber: String?
   let destination: String?
   let time: String? // Expected time of arrival
   let publicId: String?
}



/* MARK: - Estimation */

// Data model adjusted for the app.

struct Estimation: Codable, Identifiable, Equatable {
   let routeNumber: String
   let destination: String
   let publicId: String
   let timeLeft: String

   var id: String {
      return UUID().uuidString
   }

}
