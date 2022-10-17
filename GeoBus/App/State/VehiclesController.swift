//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

@MainActor
class VehiclesController: ObservableObject {
   
   /* MARK: - VARIABLES */

   private var routeNumber: String?

   @Published var vehicles: [VehicleSummary] = []



   /* MARK: - SELECTORS */

   // Getters and Setters for published and private variables.

   func set(route: String) {
      Task {
         self.routeNumber = route
         self.vehicles.removeAll()
         await self.fetchVehiclesFromCarrisAPI()
      }
   }

   func deselect() {
      self.routeNumber = nil
      self.vehicles.removeAll()
   }


   
   /* MARK: - FETCH VEHICLES SUMMARY FROM CARRIS API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.

   func fetchVehiclesFromCarrisAPI() async {
      
      // Check if there is a routeNumber selected
      if (routeNumber != nil) {
         
         Appstate.shared.change(to: .loading, for: .vehicles)

         do {
            // Request API Routes List
            var requestAPIVehiclesList = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/vehicleStatuses/routeNumber/\(routeNumber!)")!)
            requestAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
            requestAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Accept")
            requestAPIVehiclesList.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
            let (rawDataAPIVehiclesList, rawResponseAPIVehiclesList) = try await URLSession.shared.data(for: requestAPIVehiclesList)
            let responseAPIVehiclesList = rawResponseAPIVehiclesList as? HTTPURLResponse

            // Check status of response
            if (responseAPIVehiclesList?.statusCode == 401) {
               await CarrisAuthentication.shared.authenticate()
               await self.fetchVehiclesFromCarrisAPI()
            } else if (responseAPIVehiclesList?.statusCode != 200) {
               print(responseAPIVehiclesList as Any)
               throw Appstate.ModuleError.carris_unavailable
            }

            let decodedAPIVehiclesList = try JSONDecoder().decode([CarrisAPIVehicleSummary].self, from: rawDataAPIVehiclesList)


            // Define a temporary variable to store vehicles
            // before publishing and displaying them in the map.
            var tempAllVehicles: [VehicleSummary] = []

            // For each available vehicles in the API,
            for vehicleSummary in decodedAPIVehiclesList {

               // Discard vehicles with outdated location,
               // here decided to be 180 seconds (3 minutes).
               if (Helpers.getLastSeenTime(since: vehicleSummary.lastGpsTime ?? "") < 180) {

                  // Format and append each vehicle
                  // to the temporary variable.
                  tempAllVehicles.append(
                     VehicleSummary(
                        busNumber: vehicleSummary.busNumber ?? -1,
                        state: vehicleSummary.state ?? "",
                        routeNumber: vehicleSummary.routeNumber ?? "-",
                        kind: Helpers.getKind(by: vehicleSummary.routeNumber ?? "-"),
                        lat: vehicleSummary.lat ?? 0,
                        lng: vehicleSummary.lng ?? 0,
                        previousLatitude: vehicleSummary.previousLatitude ?? 0,
                        previousLongitude: vehicleSummary.previousLongitude ?? 0,
                        lastGpsTime: vehicleSummary.lastGpsTime ?? "",
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

            Appstate.shared.change(to: .idle, for: .vehicles)

         } catch {
            Appstate.shared.change(to: .error, for: .vehicles)
            print("ERROR IN VEHICLES: \(error)")
            return
         }

      }
      
   }

   

   /* MARK: - FETCH VEHICLE DETAILS FROM CARRIS API */

   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.

   func fetchVehicleDetailsFromCarrisAPI(for busNumber: Int) async -> VehicleDetails? {

      Appstate.shared.change(to: .loading, for: .vehicles)

      do {

         // Request Vehicle Detail (SGO)
         var requestAPIVehicleDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/SGO/busNumber/\(busNumber)")!)
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIVehicleDetail.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIVehicleDetail, rawResponseAPIVehicleDetail) = try await URLSession.shared.data(for: requestAPIVehicleDetail)
         let responseAPIVehicleDetail = rawResponseAPIVehicleDetail as? HTTPURLResponse

         // Check status of response
         if (responseAPIVehicleDetail?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            return await self.fetchVehicleDetailsFromCarrisAPI(for: busNumber)
         } else if (responseAPIVehicleDetail?.statusCode != 200) {
            print(responseAPIVehicleDetail as Any)
            throw Appstate.ModuleError.carris_unavailable
         }

         let decodedAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIVehicleDetail.self, from: rawDataAPIVehicleDetail)

         // Format and append each vehicle
         // to the temporary variable.
         let result = VehicleDetails(
            busNumber: busNumber,
            vehiclePlate: decodedAPIVehicleDetail.vehiclePlate,
            lastStopOnVoyageName: decodedAPIVehicleDetail.lastStopOnVoyageName ?? "-"
         )

         Appstate.shared.change(to: .idle, for: .vehicles)

         return result

      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLE DETAILS: \(error)")
         return nil
      }

   }
   
   
   
   /* MARK: - CALCULATE ANGLE IN RADIANS FOR VEHICLE DIRECTION */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   
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
