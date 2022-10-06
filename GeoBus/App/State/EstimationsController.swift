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
class EstimationsController: ObservableObject {

   /* MARK: - Variables */

   private let storageKeyForEstimationsProvider: String = "estimations_estimationsProvider"
   @Published var estimationsProvider: EstimationsProvider = .community



   /* MARK: - INITIALIZER */

   // Retrieve data from UserDefaults on init.

   init() {
      self.getProviderFromStorage()
   }



   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */

   private var appstate = Appstate()
   private var authentication = Authentication()

   public func receive(state: Appstate, auth: Authentication) {
      self.appstate = state
      self.authentication = auth
   }
   
   
   
   /* MARK: - GET ESTIMATIONS PROVIDER FROM STORAGE */
   
   // Retrieve Estimations Provider from device storage.
   
   private func getProviderFromStorage() {
      if let unwrappedEstimationsProvider = UserDefaults.standard.string(forKey: storageKeyForEstimationsProvider) {
         self.estimationsProvider = EstimationsProvider(rawValue: unwrappedEstimationsProvider) ?? .carris
      }
   }
   
   
   
   /* MARK: - SET ESTIMATIONS PROVIDER */
   
   // Set Estimations Provider for current session and save it to device storage.
   
   public func setProvider(selection: EstimationsProvider) {
      self.estimationsProvider = selection
      UserDefaults.standard.set(estimationsProvider.rawValue, forKey: storageKeyForEstimationsProvider)
      print("Provider is \(selection)")
   }



   /* MARK: - GET ESTIMATIONS */

   // This function initiates the correct API calls according to the set Estimations provider.

   public func get(for publicId: String) async -> [Estimation] {
      switch estimationsProvider {
         case .carris:
            return await self.getCarrisEstimation(for: publicId)
         case .community:
            return await self.getCommunityEstimation(for: publicId)
      }
   }


   
   /* MARK: - GET ESTIMATIONS › CARRIS */

   // This function calls Carris API to retrieve estimations for the given stop 'publicId'.
   // It formats and returns the results to the caller.

   private func getCarrisEstimation(for publicId: String) async -> [Estimation] {

      appstate.change(to: .loading, for: .estimations)

      do {
         // Request API Routes List
         var requestCarrisAPIEstimations = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/Estimations/busStop/\(publicId)/top/5")!)
         requestCarrisAPIEstimations.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIEstimations.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIEstimations.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIEstimations, rawResponseCarrisAPIEstimations) = try await URLSession.shared.data(for: requestCarrisAPIEstimations)
         let responseCarrisAPIEstimations = rawResponseCarrisAPIEstimations as? HTTPURLResponse

         // Check status of response
         if (responseCarrisAPIEstimations?.statusCode == 401) {
            Task {
               await self.authentication.authenticate()
               return await self.getCarrisEstimation(for: publicId)
            }
         } else if (responseCarrisAPIEstimations?.statusCode != 200) {
            print(responseCarrisAPIEstimations as Any)
            throw Appstate.CarrisAPIError.unavailable
         }

         let decodedCarrisAPIEstimations = try JSONDecoder().decode([CarrisAPIEstimation].self, from: rawDataCarrisAPIEstimations)

         // Define a temporary variable to store vehicles
         // before publishing and displaying them in the map.
         var tempAllEstimations: [Estimation] = []

         // For each available vehicles in the API
         for estimation in decodedCarrisAPIEstimations {

            // Format and append each estimation
            // to the temporary variable.
            tempAllEstimations.append(
               Estimation(
                  routeNumber: estimation.routeNumber ?? "-",
                  destination: estimation.destination ?? "-",
                  publicId: estimation.publicId ?? "-",
                  eta: estimation.time ?? ""
               )
            )

         }

         appstate.change(to: .idle, for: .estimations)

         // Return the formatted estimations.
         return tempAllEstimations

      } catch {
         appstate.change(to: .error, for: .estimations)
         print("GB: ERROR IN ESTIMATIONS: \(error)")
         return []
      }

   }


   /* MARK: - GET ESTIMATIONS › COMMUNITY (WHILE API IS NOT FINAL) */

   // THIS IS NOT FINAL BECAUSE IT RELIES ON CARRIS API
   // CLOSE TO FINAL VERSION IS BELLOW IN COMMENTS

   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.

   private func getCommunityEstimation(for publicId: String) async -> [Estimation] {

      appstate.change(to: .loading, for: .estimations)

      do {

         // Define a temporary variable to store vehicles
         // before publishing and displaying them in the map.
         var tempAllEstimations: [Estimation] = []

         let carrisEstimations = await getCarrisEstimation(for: publicId)

         for carrisEstimation in carrisEstimations {

            // Request API Routes List
            var requestCommunityAPIEstimations = URLRequest(url: URL(string: "https://api.carril.workers.dev/estimate?route=\(carrisEstimation.routeNumber)&id=\(publicId)")!)
            requestCommunityAPIEstimations.addValue("application/json", forHTTPHeaderField: "Content-Type")
            requestCommunityAPIEstimations.addValue("application/json", forHTTPHeaderField: "Accept")
            let (rawDataCommunityAPIEstimations, rawResponseCommunityAPIEstimations) = try await URLSession.shared.data(for: requestCommunityAPIEstimations)
            let responseCommunityAPIEstimations = rawResponseCommunityAPIEstimations as? HTTPURLResponse

            // Check status of response
            if (responseCommunityAPIEstimations?.statusCode != 200) {
               print(responseCommunityAPIEstimations as Any)
               throw Appstate.CommunityAPIError.unavailable
            }

            let decodedCommunityAPIEstimations = try JSONDecoder().decode([CommunityAPIEstimation].self, from: rawDataCommunityAPIEstimations)

            print("GB: \(decodedCommunityAPIEstimations)")

            // For each available vehicles in the API
            for estimation in decodedCommunityAPIEstimations {

               // If the vehicle is not expected to have arrived
               if (!(estimation.estimatedRecentlyArrived ?? false)) {

                  // Format and append each estimation
                  // to the temporary variable.
                  tempAllEstimations.append(
                     Estimation(
                        routeNumber: carrisEstimation.routeNumber,
                        destination: carrisEstimation.destination,
                        publicId: publicId,
                        eta: estimation.estimatedTimeofArrivalCorrected ?? ""
                     )
                  )

               }

            }

            try await Task.sleep(nanoseconds: 100_000_000)

         }

         appstate.change(to: .idle, for: .estimations)

         // Return the formatted estimations.
         return tempAllEstimations

      } catch {
         appstate.change(to: .error, for: .estimations)
         print("GB: ERROR IN ESTIMATIONS: \(error)")
         return []
      }

   }



//   /* MARK: - Get Community Estimations */
//
//   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
//   // It formats and returns the results to the caller.
//
//   func getCommunityEstimation(for publicId: String) async -> [Estimation] {
//
//      appstate.change(to: .loading, for: .estimations)
//
//      let routeNumber = "760"
//      let direction = "ASC"
//
//      do {
//         // Request API Routes List
//         var requestCommunityAPIEstimations = URLRequest(url: URL(string: "https://api.carril.workers.dev/estimate?route=\(routeNumber)&id=\(publicId)&dir=\(direction)")!)
//         requestCommunityAPIEstimations.addValue("application/json", forHTTPHeaderField: "Content-Type")
//         requestCommunityAPIEstimations.addValue("application/json", forHTTPHeaderField: "Accept")
//         let (rawDataCommunityAPIEstimations, rawResponseCommunityAPIEstimations) = try await URLSession.shared.data(for: requestCommunityAPIEstimations)
//         let responseCommunityAPIEstimations = rawResponseCommunityAPIEstimations as? HTTPURLResponse
//
//         // Check status of response
//         if (responseCommunityAPIEstimations?.statusCode != 200) {
//            print(responseCommunityAPIEstimations as Any)
//            throw Appstate.CommunityAPIError.unavailable
//         }
//
//         let decodedCommunityAPIEstimations = try JSONDecoder().decode([CommunityAPIEstimation].self, from: rawDataCommunityAPIEstimations)
//
//         // Define a temporary variable to store vehicles
//         // before publishing and displaying them in the map.
//         var tempAllEstimations: [Estimation] = []
//
//         // For each available vehicles in the API
//         for estimation in decodedCommunityAPIEstimations {
//
//            // If the vehicle is not expected to have arrived
//            if (!(estimation.estimatedRecentlyArrived ?? false)) {
//
//               // Format and append each estimation
//               // to the temporary variable.
//               tempAllEstimations.append(
//                  Estimation(
//                     routeNumber: routeNumber,
//                     destination: "Unknown",
//                     publicId: publicId,
//                     eta: estimation.estimatedTimeofArrivalCorrected ?? "" // Globals().getTimeString(for: estimation.estimatedTimeofArrivalCorrected ?? "", in: .future, style: .short, units: [.hour, .minute])
//                  )
//               )
//
//            }
//
//         }
//
//         appstate.change(to: .idle, for: .estimations)
//
//         // Return the formatted estimations.
//         return tempAllEstimations
//
//      } catch {
//         appstate.change(to: .error, for: .estimations)
//         print("ERROR IN ESTIMATIONS: \(error)")
//         return []
//      }
//
//   }


}
