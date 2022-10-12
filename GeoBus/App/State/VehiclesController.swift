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

   @Published var allVehicles: [Vehicle] = []
   @Published var vehicles: [VehicleSummary] = []
   
   
   
   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */

   var appstate = Appstate()
   var analytics = Analytics()
   var authentication = Authentication()

   func receive(state: Appstate, auth: Authentication) {
      self.appstate = state
      self.authentication = auth
   }



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
         
         appstate.change(to: .loading, for: .vehicles)

         do {
            // Request API Routes List
            var requestAPIVehiclesList = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/vehicleStatuses/routeNumber/\(routeNumber!)")!)
            requestAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
            requestAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Accept")
            requestAPIVehiclesList.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
            let (rawDataAPIVehiclesList, rawResponseAPIVehiclesList) = try await URLSession.shared.data(for: requestAPIVehiclesList)
            let responseAPIVehiclesList = rawResponseAPIVehiclesList as? HTTPURLResponse

            // Check status of response
            if (responseAPIVehiclesList?.statusCode == 401) {
               Task {
                  await self.authentication.authenticate()
                  await self.fetchVehiclesFromCarrisAPI()
               }
               return
            } else if (responseAPIVehiclesList?.statusCode != 200) {
               print(responseAPIVehiclesList as Any)
               throw Appstate.CarrisAPIError.unavailable
            }

            let decodedAPIVehiclesList = try JSONDecoder().decode([CarrisAPIVehicleSummary].self, from: rawDataAPIVehiclesList)


            // Define a temporary variable to store vehicles
            // before publishing and displaying them in the map.
            var tempAllVehicles: [VehicleSummary] = []

            // For each available vehicles in the API,
            for vehicleSummary in decodedAPIVehiclesList {

               // Discard vehicles with outdated location,
               // here decided to be 180 seconds (3 minutes).
               if (Globals().getLastSeenTime(since: vehicleSummary.lastGpsTime ?? "") < 180) {

                  // Format and append each vehicle
                  // to the temporary variable.
                  tempAllVehicles.append(
                     VehicleSummary(
                        busNumber: vehicleSummary.busNumber ?? -1,
                        state: vehicleSummary.state ?? "",
                        routeNumber: vehicleSummary.routeNumber ?? "-",
                        kind: Globals().getKind(by: vehicleSummary.routeNumber ?? "-"),
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

            appstate.change(to: .idle, for: .vehicles)

         } catch {
            appstate.change(to: .error, for: .vehicles)
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

      appstate.change(to: .loading, for: .vehicles)

      do {

         // Request Vehicle Detail (SGO)
         var requestAPIVehicleDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/SGO/busNumber/\(busNumber)")!)
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIVehicleDetail.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIVehicleDetail, rawResponseAPIVehicleDetail) = try await URLSession.shared.data(for: requestAPIVehicleDetail)
         let responseAPIVehicleDetail = rawResponseAPIVehicleDetail as? HTTPURLResponse

         // Check status of response
         if (responseAPIVehicleDetail?.statusCode == 401) {
            Task {
               await self.authentication.authenticate()
               return await self.fetchVehicleDetailsFromCarrisAPI(for: busNumber)
            }
            return nil
         } else if (responseAPIVehicleDetail?.statusCode != 200) {
            print(responseAPIVehicleDetail as Any)
            throw Appstate.CarrisAPIError.unavailable
         }

         let decodedAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIVehicleDetail.self, from: rawDataAPIVehicleDetail)

         // Format and append each vehicle
         // to the temporary variable.
         let result = VehicleDetails(
            busNumber: busNumber,
            vehiclePlate: decodedAPIVehicleDetail.vehiclePlate ?? "",
            lastStopOnVoyageName: decodedAPIVehicleDetail.lastStopOnVoyageName ?? "-"
         )

         appstate.change(to: .idle, for: .vehicles)

         return result

      } catch {
         appstate.change(to: .error, for: .vehicles)
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
   
   
   
   /* MARK: - FETCH VEHICLE FROM COMMUNITY API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.
   
   func fetchVehicleFromCommunityAPI(for busNumber: Int) async -> VehicleDetails? {
      
      appstate.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestAPIVehicleDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/SGO/busNumber/\(busNumber)")!)
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIVehicleDetail.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIVehicleDetail, rawResponseAPIVehicleDetail) = try await URLSession.shared.data(for: requestAPIVehicleDetail)
         let responseAPIVehicleDetail = rawResponseAPIVehicleDetail as? HTTPURLResponse
         
         // Check status of response
         if (responseAPIVehicleDetail?.statusCode == 401) {
            Task {
               await self.authentication.authenticate()
               return await self.fetchVehicleDetailsFromCarrisAPI(for: busNumber)
            }
            return nil
         } else if (responseAPIVehicleDetail?.statusCode != 200) {
            print(responseAPIVehicleDetail as Any)
            throw Appstate.CarrisAPIError.unavailable
         }
         
         let decodedAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIVehicleDetail.self, from: rawDataAPIVehicleDetail)
         
         // Format and append each vehicle
         // to the temporary variable.
         let result = VehicleDetails(
            busNumber: busNumber,
            vehiclePlate: decodedAPIVehicleDetail.vehiclePlate ?? "",
            lastStopOnVoyageName: decodedAPIVehicleDetail.lastStopOnVoyageName ?? "-"
         )
         
         appstate.change(to: .idle, for: .vehicles)
         
         return result
         
      } catch {
         appstate.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLE DETAILS: \(error)")
         return nil
      }
      
   }
   
   
   
   
   //
   //
   //
   //
   // N E W  V E R S I O N
   //
   //
   //
   //
   
   
   
   
   
   /* MARK: - UPDATE VEHICLES */
   
   // This function decides whether to update available routes
   
   enum VehicleUpdateScope {
      case summary
      case detail
      case community
   }
   
   func update(scope: VehicleUpdateScope, for busNumber: Int? = nil) {
      
      switch scope {
            
         case .summary:
            Task {
               await fetchVehiclesListFromCarrisAPI_NEW()
            }
            
         case .detail:
            if (busNumber != nil) {
               Task {
                  await fetchVehicleDetailsFromCarrisAPI_NEW(for: busNumber!)
               }
            }
            
         case .community:
            if (busNumber != nil) {
               Task {
                  await fetchVehicleFromCommunityAPI_NEW(for: busNumber!)
               }
            }
            
      }
      
   }
   
   
   
   /* MARK: - FETCH VEHICLES SUMMARY FROM CARRIS API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.
   
   func fetchVehiclesListFromCarrisAPI_NEW() async {
      
      appstate.change(to: .loading, for: .vehicles)
      
      do {
         // Request all Vehicles from API
         var requestCarrisAPIVehiclesList = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/vehicleStatuses")!) // /routeNumber/\(routeNumber!)
         requestCarrisAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIVehiclesList.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIVehiclesList, rawResponseCarrisAPIVehiclesList) = try await URLSession.shared.data(for: requestCarrisAPIVehiclesList)
         let responseCarrisAPIVehiclesList = rawResponseCarrisAPIVehiclesList as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIVehiclesList?.statusCode == 401) {
            await self.authentication.authenticate()
            await self.fetchVehiclesListFromCarrisAPI_NEW()
            return
         } else if (responseCarrisAPIVehiclesList?.statusCode != 200) {
            print(responseCarrisAPIVehiclesList as Any)
            throw Appstate.CarrisAPIError.unavailable
         }
         
         let decodedCarrisAPIVehiclesList = try JSONDecoder().decode([CarrisAPIVehicleSummary].self, from: rawDataCarrisAPIVehiclesList)
         
         
         for vehicleSummary in decodedCarrisAPIVehiclesList {
            
            let indexOfVehicleInArray = self.allVehicles.firstIndex(where: {
               $0.id == vehicleSummary.busNumber
            })
            
            if (indexOfVehicleInArray != nil) {
               allVehicles[indexOfVehicleInArray!].routeNumber = vehicleSummary.routeNumber ?? "-"
               allVehicles[indexOfVehicleInArray!].kind = Globals().getKind(by: vehicleSummary.routeNumber ?? "-")
               allVehicles[indexOfVehicleInArray!].lat = vehicleSummary.lat ?? 0
               allVehicles[indexOfVehicleInArray!].lng = vehicleSummary.lng ?? 0
               allVehicles[indexOfVehicleInArray!].previousLatitude = vehicleSummary.previousLatitude ?? 0
               allVehicles[indexOfVehicleInArray!].previousLongitude = vehicleSummary.previousLongitude ?? 0
               allVehicles[indexOfVehicleInArray!].lastGpsTime = vehicleSummary.lastGpsTime ?? ""
               allVehicles[indexOfVehicleInArray!].angleInRadians = self.getAngleInRadians(
                  prevLat: vehicleSummary.previousLatitude ?? 0,
                  prevLng: vehicleSummary.previousLongitude ?? 0,
                  currLat: vehicleSummary.lat ?? 0,
                  currLng: vehicleSummary.lng ?? 0
               )
            } else {
               self.allVehicles.append(
                  Vehicle(
                     busNumber: vehicleSummary.busNumber ?? 0,
                     routeNumber: vehicleSummary.routeNumber ?? "-",
                     kind: Globals().getKind(by: vehicleSummary.routeNumber ?? "-"),
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
         
         appstate.change(to: .idle, for: .vehicles)
         
      } catch {
         appstate.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLES: \(error)")
         return
      }
      
   }
   
   
   
   
   
   
   
   
   /* MARK: - FETCH VEHICLE DETAILS FROM CARRIS API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.
   
   func fetchVehicleDetailsFromCarrisAPI_NEW(for busNumber: Int) async {
      
      // 1. Check if Vehicle exists in array
      guard let indexOfVehicleInArray = allVehicles.firstIndex(where: { $0.id == busNumber }) else {
         return
      }
      
      appstate.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestCarrisAPIVehicleDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/SGO/busNumber/\(busNumber)")!)
         requestCarrisAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIVehicleDetail.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIVehicleDetail, rawResponseCarrisAPIVehicleDetail) = try await URLSession.shared.data(for: requestCarrisAPIVehicleDetail)
         let responseCarrisAPIVehicleDetail = rawResponseCarrisAPIVehicleDetail as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIVehicleDetail?.statusCode == 401) {
            await self.authentication.authenticate()
            await self.fetchVehicleDetailsFromCarrisAPI_NEW(for: busNumber)
            return
         } else if (responseCarrisAPIVehicleDetail?.statusCode != 200) {
            print(responseCarrisAPIVehicleDetail as Any)
            throw Appstate.CarrisAPIError.unavailable
         }
         
         let decodedCarrisAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIVehicleDetail.self, from: rawDataCarrisAPIVehicleDetail)
         
         // Update details of Vehicle
         allVehicles[indexOfVehicleInArray].vehiclePlate = decodedCarrisAPIVehicleDetail.vehiclePlate ?? "-"
         allVehicles[indexOfVehicleInArray].lastStopOnVoyageName = decodedCarrisAPIVehicleDetail.lastStopOnVoyageName ?? "-"
         
         appstate.change(to: .idle, for: .vehicles)
         
      } catch {
         appstate.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLE DETAILS: \(error)")
         return
      }
      
   }
   
   
   
   /* MARK: - FETCH VEHICLE FROM COMMUNITY API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.
   
   func fetchVehicleFromCommunityAPI_NEW(for busNumber: Int) async {
      
      // 1. Check if Vehicle exists in array
      guard let indexOfVehicleInArray = allVehicles.firstIndex(where: { $0.id == busNumber }) else {
         return
      }
      
      appstate.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestCommunityAPIVehicle = URLRequest(url: URL(string: "https://api.carril.workers.dev/estbus?busNumber=\(busNumber)")!)
         requestCommunityAPIVehicle.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCommunityAPIVehicle.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCommunityAPIVehicle.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCommunityAPIVehicle, rawResponseCommunityAPIVehicle) = try await URLSession.shared.data(for: requestCommunityAPIVehicle)
         let responseCommunityAPIVehicle = rawResponseCommunityAPIVehicle as? HTTPURLResponse
         
         // Check status of response
         if (responseCommunityAPIVehicle?.statusCode != 200) {
            print(responseCommunityAPIVehicle as Any)
            throw Appstate.CommunityAPIError.unavailable
         }
         
         let decodedCommunityAPIVehicle = try JSONDecoder().decode([CommunityAPIVehicle].self, from: rawDataCommunityAPIVehicle)
         
         // Update details of Vehicle
         allVehicles[indexOfVehicleInArray].estimatedTimeofArrivalCorrected = decodedCommunityAPIVehicle[0].estimatedTimeofArrivalCorrected
         
         appstate.change(to: .idle, for: .vehicles)
         
      } catch {
         appstate.change(to: .error, for: .vehicles)
         print("GB: ERROR IN 'fetchVehicleFromCommunityAPI_NEW': \(error)")
         return
      }
      
   }
   
   
   
   
   
   func getVehicle(by busNumber: Int) -> Vehicle? {
      let indexInArray = self.allVehicles.firstIndex(where: {
         $0.busNumber == busNumber
      })
      
      if (indexInArray != nil) {
         return allVehicles[indexInArray!]
      } else {
         return nil
      }
   }
   
   
   
   
   
}
