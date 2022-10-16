//
//  Routes.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//
import Foundation


/* * */
/* MARK: - CARRIS API DATA MODEL */
/* Data model as provided by Carris API. */
/* Schema is available at https://joaodcp.github.io/Carris-API */

struct CarrisAPIRoutesList: Decodable {
   let id: Int?
   let routeNumber: String?
   let name: String?
   let isPublicVisible: Bool?
   let timestamp: String?
}

struct CarrisAPIRoute: Decodable {
   let isCirc: Bool?
   let variants: [APIRouteVariant]?
   let id: Int?
   let routeNumber: String?
   let name: String?
   let isPublicVisible: Bool?
   let timestamp: String?
}

struct CarrisAPIRouteVariant: Decodable {
   let id: Int?
   let variantNumber: Int?
   let isActive: Bool?
   let upItinerary, downItinerary, circItinerary: APIRouteVariantItinerary?
}

struct CarrisAPIRouteVariantItinerary: Decodable {
   let id: Int?
   let type: String?
   let connections: [APIRouteVariantItineraryConnection]?
}

struct CarrisAPIRouteVariantItineraryConnection: Decodable {
   let id, distance, orderNum: Int?
   let busStop: APIStop?
}

struct CarrisAPIStop: Decodable {
   let id: Int?
   let name, publicId: String?
   let lat, lng: Double?
   let isPublicVisible: Bool?
   let timestamp: String?
}

struct CarrisAPIVehicleSummary: Decodable {
   let busNumber: Int?
   let state: String?
   let lastGpsTime: String?
   let lastReportTime: String?
   let lat: Double?
   let lng: Double?
   let routeNumber: String?
   let direction: String?
   let plateNumber: String?
   let timeStamp: String?
   let dataServico: String?
   let previousReportTime: String?
   let previousLatitude: Double?
   let previousLongitude: Double?
}

struct CarrisAPIVehicleDetail: Codable {
   let vehiclePlate: String?
   let routeNumber: String?
   let plateNumber: String?
   let direction: String?
   let lastStopOnVoyageId: Int?
   let lastStopOnVoyageName: String?
   let parkingStopId: Int?
   let parkingStopName: String?
   let driverNumber: String?
   let lat: Double?
   let lng: Double?
}

struct CarrisAPIEstimation: Decodable {
   let routeNumber: String?
   let routeName: String?
   let destination: String?
   let time: String? // Expected time of arrival
   let busNumber: String?
   let plateNumber: String?
   let voyageNumber: Int
   let publicId: String?
}
