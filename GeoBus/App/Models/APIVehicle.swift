//
//  Vehicle.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation

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
