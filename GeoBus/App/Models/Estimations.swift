//
//  Estimations.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

/* MARK: - Estimations Provider */

// Different providers for Estimations.

enum EstimationsProvider: String {
   case carris
   case community
}


/* MARK: - API Estimation */

// Data model as provided by Carris API.
// Schema is available at https://joaodcp.github.io/Carris-API

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


// Data model as provided by Community API.
// Schema is currently not available...

struct CommunityAPIEstimation: Decodable {
   let busNumber: Int?
   let enrichedAvgRouteSpeed: Double?
   let enrichedBusSpeed: Double?
   let enrichedEstRouteKm: Double?
   let enrichedQueryTime: Int?
   let enrichedSequenceNo: Int?
   let enrichedStartTime: String?
//   "estimatedDebug":[
//      "Info: currentBusStopArrivals: This bus is NOT expected to have passed this stop already in the current route.",
//      "Info: timeDeltaList: corrected estimate computed with speed correction factors 0.8543648255362379 and 0.6507523601990874.",
//      "Info: timeDeltaList: estimate computed from 28 historical samples."
//   ]
   let estimatedRecentlyArrived: Bool?
   let estimatedTimeofArrival: String?
   let estimatedTimeofArrivalCorrected: String?
   let estimatedTimeofArrivalCorrected_debug_alternative: String?
   let estimatedUncertainty: String?
   let lastReportTime: String?
   let lat, long: Double?
   let previousLatitude, previousLongitude: Double?
   let variantNumber: Int?
}



/* MARK: - Estimation */

// Data model adjusted for the app.

struct Estimation: Codable, Identifiable, Equatable {
   let routeNumber: String
   let destination: String
   let publicId: String
   let eta: String

   var id: String {
      return UUID().uuidString
   }

}
