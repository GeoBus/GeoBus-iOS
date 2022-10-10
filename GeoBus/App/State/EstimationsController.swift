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
      print("GB: Provider is \(selection)")
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
                  busNumber: estimation.busNumber ?? "-",
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
   
   
   /* MARK: - GET ESTIMATIONS › COMMUNITY */
   
   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.
   
   func getCommunityEstimation(for publicId: String) async -> [Estimation] {
      
      appstate.change(to: .loading, for: .estimations)
      
      do {
         // Request API Routes List
         var requestCommunityAPIVehicle = URLRequest(url: URL(string: "https://api.carril.workers.dev/eststop?busStop=\(publicId)")!)
         requestCommunityAPIVehicle.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCommunityAPIVehicle.addValue("application/json", forHTTPHeaderField: "Accept")
         let (rawDataCommunityAPIVehicle, rawResponseCommunityAPIVehicle) = try await URLSession.shared.data(for: requestCommunityAPIVehicle)
         let responseCommunityAPIVehicle = rawResponseCommunityAPIVehicle as? HTTPURLResponse
         
         // Check status of response
         if (responseCommunityAPIVehicle?.statusCode != 200) {
            print(responseCommunityAPIVehicle as Any)
            throw Appstate.CommunityAPIError.unavailable
         }
         
         let decodedCommunityAPIVehicle = try JSONDecoder().decode([CommunityAPIVehicle].self, from: rawDataCommunityAPIVehicle)
         
         // Define a temporary variable to store vehicles
         // before publishing and displaying them in the map.
         var tempAllEstimations: [Estimation] = []
         
         // For each available vehicles in the API
         for communityVehicle in decodedCommunityAPIVehicle {
            
            // If the vehicle is not expected to have arrived
            if (!(communityVehicle.estimatedRecentlyArrived ?? false)) {
               
               let carrisVehicleDetails = await VehiclesController().fetchVehicleDetailsFromCarrisAPI(for: communityVehicle.busNumber ?? 0)
               
               // Format and append each estimation
               // to the temporary variable.
               tempAllEstimations.append(
                  Estimation(
                     routeNumber: communityVehicle.routeNumber ?? "-",
                     destination: carrisVehicleDetails?.lastStopOnVoyageName ?? "-",
                     publicId: publicId,
                     busNumber: String(communityVehicle.busNumber ?? 0),
                     eta: communityVehicle.estimatedTimeofArrivalCorrected ?? ""
                  )
               )
               
            }
            
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
