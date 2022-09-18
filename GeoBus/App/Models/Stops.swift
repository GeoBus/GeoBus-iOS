//
//  Stops.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import CoreLocation

/* MARK: - API Stop */

// Data models as provided by the API.
// Schema is available at https://joaodcp.github.io/Carris-API

struct APIStop: Decodable {
   let id: Int?
   let name, publicId: String?
   let lat, lng: Double?
   let isPublicVisible: Bool?
   let timestamp: String?
}



/* MARK: - Stop */

// Data models adjusted for the app.

struct Stop: Codable, Equatable, Identifiable {
   let publicId: String
   let name: String
   let lat, lng: Double
   let orderInRoute: Int?
   let direction: Direction?

   var id: String {
      return self.publicId //UUID().uuidString
   }
}
