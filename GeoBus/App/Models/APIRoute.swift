//
//  RawRouteResponse.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct APIRoutesList: Decodable {
   let id: Int
   let routeNumber: String
   let name: String
   let isPublicVisible: Bool
   let timestamp: String
}

struct APIRoute: Decodable {
   let isCirc: Bool
   let variants: [APIRouteVariant]
   let id: Int
   let routeNumber: String
   let name: String
   let isPublicVisible: Bool
   let timestamp: String
}

struct APIRouteVariant: Decodable {
   let id: Int
   let variantNumber: Int
   let isActive: Bool
   let upItinerary, downItinerary, circItinerary: APIRouteVariantItinerary?
}

struct APIRouteVariantItinerary: Decodable {
   let id: Int
   let type: String
   let connections: [APIRouteVariantItineraryConnection]
}

struct APIRouteVariantItineraryConnection: Decodable {
   let id, distance, orderNum: Int
   let busStop: APIRouteVariantItineraryConnectionBusStop
}

struct APIRouteVariantItineraryConnectionBusStop: Decodable {
   let id: Int
   let name, publicId: String
   let lat, lng: Double
   let isPublicVisible: Bool
   let timestamp: String
}
