//
//  Routes.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import CoreLocation

enum RouteVariantDirection: Codable {
   case ascending
   case descending
   case circular
}

struct Route: Codable, Equatable, Identifiable {
   let number: String
   let name: String
   let kind: Kind
   let variants: [RouteVariant]

   var id: String {
      return self.number
   }

}

struct RouteVariant: Codable, Equatable, Identifiable {
   let number: Int
   var name: String = ""
   let isCircular: Bool
   var upItinerary, downItinerary, circItinerary: [RouteVariantStop]?

   var id: String {
      return self.name
   }

}

struct RouteVariantStop: Codable, Equatable, Identifiable {
   let orderInRoute: Int
   let publicId: String
   let name: String
   let direction: RouteVariantDirection
   let lat, lng: Double

   var id: String {
      return self.publicId
   }

}
