////
////  Route.swift
////  GeoBus
////
////  Created by João on 19/04/2020.
////  Copyright © 2020 João. All rights reserved.
////
//
//import Foundation
//
//struct RouteDetailResponse: Codable, Identifiable, Equatable {
//   var isCirc: Bool
//   var id: Int
//   var routeNumber: String
//   let name: String
//   let isPublicVisible: Bool
//   var timestamp: String
//   var variants: [RouteVariantResponse]
//}
//
//struct RouteVariantResponse: Codable, Identifiable, Equatable {
//   var id: Int
//   var variantNumber: Int
//   let isActive: Bool
//   let name: String
//   let shape: String
//   var upItinerary: [RouteVariantItinerary]
//   var downItinerary: [RouteVariantItinerary]
//   var circItinerary: [RouteVariantItinerary]
//}
//
//struct RouteVariantItinerary: Codable, Identifiable, Equatable {
//   var id: Int
//   var type: String
//   let connections: [RouteVariantConnection]
//}
//
//struct RouteVariantConnection: Codable, Identifiable, Equatable {
//   var id: Int
//   var distance: Int
//   var orderNum: Int
//   var busStop: [RouteVariantStop]
//}
//
//struct RouteVariantStop: Codable, Identifiable, Equatable {
//   var id: Int
//   var name: String
//   var publicId: String
//   var lat: Double
//   var lng: Double
//   var isPublicVisible: Bool
//   var timestamp: String
//}
//
