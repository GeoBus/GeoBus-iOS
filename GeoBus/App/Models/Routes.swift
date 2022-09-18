//
//  Routes.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import CoreLocation

/* MARK: - API Route */

// Data models as provided by the API.
// Schema is available at https://joaodcp.github.io/Carris-API

struct APIRoutesList: Decodable {
   let id: Int?
   let routeNumber: String?
   let name: String?
   let isPublicVisible: Bool?
   let timestamp: String?
}

struct APIRoute: Decodable {
   let isCirc: Bool?
   let variants: [APIRouteVariant]?
   let id: Int?
   let routeNumber: String?
   let name: String?
   let isPublicVisible: Bool?
   let timestamp: String?
}

struct APIRouteVariant: Decodable {
   let id: Int?
   let variantNumber: Int?
   let isActive: Bool?
   let upItinerary, downItinerary, circItinerary: APIRouteVariantItinerary?
}

struct APIRouteVariantItinerary: Decodable {
   let id: Int?
   let type: String?
   let connections: [APIRouteVariantItineraryConnection]?
}

struct APIRouteVariantItineraryConnection: Decodable {
   let id, distance, orderNum: Int?
   let busStop: APIStop?
}



/* MARK: - Route */

// Data models adjusted for the app.

enum Direction: Codable {
   case ascending
   case descending
   case circular
}


struct Route: Codable, Equatable, Identifiable {
   let number: String
   let name: String
   let kind: Kind
   var variants: [Variant]

   var id: String {
      return self.number
   }

}


struct Variant: Codable, Equatable, Identifiable {
   let number: Int
   var name: String = ""
   let isCircular: Bool
   var upItinerary, downItinerary, circItinerary: [Stop]?

   var id: String {
      return self.name
   }
}
