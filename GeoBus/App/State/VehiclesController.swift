//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class VehiclesController: ObservableObject {
   
   /* MARK: - Variables */
   
   private var endpoint = "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/vehicleStatuses/routeNumber/"
   
   @Published var vehicles: [Vehicle] = []
   
   private var routeNumber: String?
   
   
   
   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */

   var appstate = Appstate()
   var authentication = Authentication()

   func receive(state: Appstate, auth: Authentication) {
      self.appstate = state
      self.authentication = auth
   }



   /* MARK: - Set Current Route */
   
   func set(route: String) {
      Task {
         self.routeNumber = route
         await self.fetchVehiclesFromAPI()
      }
   }
   
   
   
   /* MARK: - Fetch Vehicles from API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.

   @MainActor
   func fetchVehiclesFromAPI() async {
      
      // Check if there is a routeNumber selected
      if (routeNumber != nil) {
         
         appstate.change(to: .loading)


         do {
            // Request API Routes List
            var requestAPIVehiclesList = URLRequest(url: URL(string: endpoint + routeNumber!)!)
            requestAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
            requestAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Accept")
            requestAPIVehiclesList.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
            let (rawDataAPIVehiclesList, rawResponseAPIVehiclesList) = try await URLSession.shared.data(for: requestAPIVehiclesList)
            let responseAPIVehiclesList = rawResponseAPIVehiclesList as? HTTPURLResponse

            // Check status of response
            if (responseAPIVehiclesList?.statusCode == 401) {
               Task {
                  await self.authentication.authenticate()
                  await self.fetchVehiclesFromAPI()
               }
               return
            } else if (responseAPIVehiclesList?.statusCode != 200) {
               print(responseAPIVehiclesList as Any)
               throw Appstate.APIError.undefined
            }

            let decodedAPIVehiclesList = try JSONDecoder().decode([APIVehicleSummary].self, from: rawDataAPIVehiclesList)


            // Define a temporary variable to store vehicles
            // before publishing and displaying them in the map.
            var tempAllVehicles: [Vehicle] = []

            // For each available vehicles in the API,
            for vehicleSummary in decodedAPIVehiclesList {

               // Discard vehicles with outdated location,
               // here decided to be 180 seconds (3 minutes).
               if (self.getLastSeenTime(since: vehicleSummary.lastGpsTime ?? "") < 180) {

                  // Request Vehicle Detail (SGO)
                  var requestAPIVehicleDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/SGO/busNumber/\(vehicleSummary.busNumber!)")!)
                  requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
                  requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
                  requestAPIVehicleDetail.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
                  let (rawDataAPIVehicleDetail, rawResponseAPIVehicleDetail) = try await URLSession.shared.data(for: requestAPIVehicleDetail)
                  let responseAPIVehicleDetail = rawResponseAPIVehicleDetail as? HTTPURLResponse

                  // Check status of response
                  if (responseAPIVehicleDetail?.statusCode == 401) {
                     Task {
                        await self.authentication.authenticate()
                        await self.fetchVehiclesFromAPI()
                     }
                     return
                  } else if (responseAPIVehicleDetail?.statusCode != 200) {
                     print(responseAPIVehicleDetail as Any)
                     throw Appstate.APIError.undefined
                  }

                  let decodedAPIVehicleDetail = try JSONDecoder().decode(APIVehicleDetail.self, from: rawDataAPIVehicleDetail)

                  // Format and append each vehicle
                  // to the temporary variable.
                  tempAllVehicles.append(
                     Vehicle(
                        busNumber: vehicleSummary.busNumber ?? 0,
                        plateNumber: vehicleSummary.plateNumber ?? "-",
                        routeNumber: vehicleSummary.routeNumber ?? "-",
                        kind: Globals().getKind(by: vehicleSummary.routeNumber ?? "-"),
                        lat: vehicleSummary.lat ?? 0,
                        lng: vehicleSummary.lng ?? 0,
                        previousLatitude: vehicleSummary.previousLatitude ?? 0,
                        previousLongitude: vehicleSummary.previousLongitude ?? 0,
                        lastGpsTime: vehicleSummary.lastGpsTime ?? "-",
                        lastStopOnVoyageName: decodedAPIVehicleDetail.lastStopOnVoyageName ?? "-",
                        lastSeenTime: self.getLastSeenTime(since: vehicleSummary.lastGpsTime ?? "-"),
                        angleInRadians: self.getAngleInRadians(
                           prevLat: vehicleSummary.previousLatitude ?? 0,
                           prevLng: vehicleSummary.previousLongitude ?? 0,
                           currLat: vehicleSummary.lat ?? 0,
                           currLng: vehicleSummary.lng ?? 0
                        )
                     )
                  )

               }

            }

            // Publish the formatted vehicles, replacing the old ones.
            self.vehicles = tempAllVehicles

         } catch {
            appstate.change(to: .error)
            print("ERROR IN VEHICLES: \(error)")
            return
         }

      }

      appstate.change(to: .idle)
      
   }
   
   
   
   func getLastSeenTime(since lastGpsTime: String) -> Int {
      
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      
      let now = Date()
      let estimation = formatter.date(from: lastGpsTime) ?? now
      
      let seconds = now.timeIntervalSince(estimation)
      
      return Int(seconds)
      
   }
   
   
   
   
   func getAngleInRadians(prevLat: Double, prevLng: Double, currLat: Double, currLng: Double) -> Double {
      // and return response to the caller
      let x = currLat - prevLat;
      let y = currLng - prevLng;
      
      var teta: Double;
      // Angle is calculated with the arctan of ( y / x )
      if (x == 0){ teta = .pi / 2 }
      else { teta = atan(y / x) }
      
      // If x is negative, then the angle is in the symetric quadrant
      if (x < 0) { teta += .pi }
      
      return teta - (.pi / 2) // Correction cuz Apple rotates clockwise
      
   }
   
   
}
