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

   @Published var estimations: [Estimation] = []



   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */

   var appstate = Appstate()
   var authentication = Authentication()

   func receive(state: Appstate, auth: Authentication) {
      self.appstate = state
      self.authentication = auth
   }



   /* MARK: - Get Estimations */

   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.

   func get(for publicId: String) async -> [Estimation] {

      appstate.change(to: .loading, for: .estimations)

      do {
         // Request API Routes List
         var requestAPIEstimations = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/Estimations/busStop/\(publicId)/top/5")!)
         requestAPIEstimations.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIEstimations.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIEstimations.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIEstimations, rawResponseAPIEstimations) = try await URLSession.shared.data(for: requestAPIEstimations)
         let responseAPIEstimations = rawResponseAPIEstimations as? HTTPURLResponse

         // Check status of response
         if (responseAPIEstimations?.statusCode == 401) {
            Task {
               await self.authentication.authenticate()
               return await self.get(for: publicId)
            }
         } else if (responseAPIEstimations?.statusCode != 200) {
            print(responseAPIEstimations as Any)
            throw Appstate.CarrisAPIError.unavailable
         }

         let decodedAPIEstimations = try JSONDecoder().decode([APIEstimation].self, from: rawDataAPIEstimations)

         // Define a temporary variable to store vehicles
         // before publishing and displaying them in the map.
         var tempAllEstimations: [Estimation] = []

         // For each available vehicles in the API
         for estimation in decodedAPIEstimations {

            // Format and append each estimation
            // to the temporary variable.
            tempAllEstimations.append(
               Estimation(
                  routeNumber: estimation.routeNumber ?? "-",
                  destination: estimation.destination ?? "-",
                  publicId: estimation.publicId ?? "-",
                  eta: Globals().getTimeString(for: estimation.time ?? "", in: .future, style: .short, units: [.hour, .minute])
               )
            )

         }

         appstate.change(to: .idle, for: .estimations)

         // Return the formatted estimations.
         return tempAllEstimations

      } catch {
         appstate.change(to: .error, for: .estimations)
         print("ERROR IN ESTIMATIONS: \(error)")
         return []
      }

   }


}
