//
//  Vehicles.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

/* MARK: - API Vehicle */

// Data model as provided by the API.
// Schema is available at https://joaodcp.github.io/Carris-API

struct APIVehicleSummary: Decodable {
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

struct APIVehicleDetail: Codable {
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



/* MARK: - Vehicle */

// Data model adjusted for the app.

struct VehicleSummary: Codable, Equatable, Identifiable {
   let busNumber: String
   let state: String
   let routeNumber: String
   let kind: Kind
   let lat: Double
   let lng: Double
   let previousLatitude: Double?
   let previousLongitude: Double?
   let lastGpsTime: String
   let angleInRadians: Double

   var id: String {
      return self.busNumber
   }
   
}


struct VehicleDetails: Codable, Equatable, Identifiable {
   let busNumber: String
   let vehiclePlate: String
   let lastStopOnVoyageName: String

   var id: String {
//      return self.busNumber + self.lastStopOnVoyageName
      return UUID().uuidString
   }

}
