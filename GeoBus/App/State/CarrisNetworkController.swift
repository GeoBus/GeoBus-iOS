//
//  RoutesController.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 08/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import Combine


/* * */
/* MARK: - CARRIS NETWORK CONTROLLER */
/* This class controls all things Network related. Keeping logic centralized */
/* allows for code reuse, less plumbing passing object from one class to another */
/* and less clutter overall. If the data is provided by Carris, it should be controlled */
/* by this class. Next follows an overview of this class and its sections: */
/* › SECTION 1: SETTINGS */
/* › SECTION 2: PUBLISHED VARIABLES */
/* › SECTION 3: INITIALIZER */
/* › SECTION 4: APPSTATE, ANALYTICS & AUTHENTICATION */
/* › SECTION 5: TITLE */
/* › SECTION 6: TITLE */
/* › SECTION 7: TITLE */
/* › SECTION 8: TITLE */
/* › SECTION 9: TITLE */
/* › SECTION 10: TITLE */
/* › SECTION 11: TITLE */


@MainActor
class CarrisNetworkController: ObservableObject {
   
   /* * */
   /* MARK: - SECTION 1: SETTINGS */
   /* In this section one can find private constants for update intervals, */
   /* storage keys and more. Change these values with caution because they can */
   /* trigger updates on the users devices, which can take a long time or fail. */
   
   private let network_updateInterval: Int = 86400 * 5 // 5 days
   private let network_storageKeyForSavedStops: String = "network_savedStops"
   private let network_storageKeyForSavedRoutes: String = "network_savedRoutes"
   private let network_storageKeyForLastUpdated: String = "network_lastUpdated"
   
   private let routes_storageKeyForFavoriteRoutes: String = "routes_favoriteRoutes"
   
   private let stops_storageKeyForFavoriteStops: String = "stops_favoriteStops"
   
   private let api_carrisEndpoint: String = "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10"
   private let api_communityEndpoint: String = "https://api.carril.workers.dev"
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 2: PUBLISHED VARIABLES */
   /* Here are all the @Published variables that can be consumed by the app views. */
   /* It is important to keep the names of this variables short, but descriptive, */
   /* to avoid clutter on the interface code. */
   
   @Published var network_allRoutes: [Route_NEW] = []
   @Published var network_allStops: [Stop_NEW] = []
   @Published var network_allVehicles: [Vehicle] = []
   
   @Published var network_lastUpdated: String? = nil
   @Published var network_updateProgress: Int? = nil
   
   @Published var network_selectedRoute: Route_NEW? = nil
   @Published var network_selectedVariant: Variant_NEW? = nil
   @Published var network_selectedConnection: Connection_NEW? = nil
   @Published var network_selectedStop: Stop_NEW? = nil
   
   @Published var favorites_routes: [Route_NEW] = []
   @Published var favorites_stops: [Stop_NEW] = []
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 3: INITIALIZER */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. Do not call other */
   /* functions yet because Appstate and Authentication must be passed first. */
   
   init() {
      
      // Unwrap and Decode Stops from Storage
      if let unwrappedSavedNetworkStops = UserDefaults.standard.data(forKey: network_storageKeyForSavedStops) {
         if let decodedSavedNetworkStops = try? JSONDecoder().decode([Stop_NEW].self, from: unwrappedSavedNetworkStops) {
            self.network_allStops = decodedSavedNetworkStops
         }
      }
      
      // Unwrap and Decode Routes from Storage
      if let unwrappedSavedNetworkRoutes = UserDefaults.standard.data(forKey: network_storageKeyForSavedRoutes) {
         if let decodedSavedNetworkRoutes = try? JSONDecoder().decode([Route_NEW].self, from: unwrappedSavedNetworkRoutes) {
            self.network_allRoutes = decodedSavedNetworkRoutes
         }
      }
      
      // Unwrap last timestamp from Storage
      if let unwrappedLastUpdatedNetwork = UserDefaults.standard.string(forKey: network_storageKeyForLastUpdated) {
         self.network_lastUpdated = unwrappedLastUpdatedNetwork
      }
      
   }
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 5: UPDATE NETWORK FROM CARRIS API */
   /* This function decides whether to update the complete network model */
   /* if it is considered outdated or is inexistent on device storage. */
   /* Provide a convenience method to allow user-requested updates from the UI. */
   
   func resetAndUpdateNetwork() {
      self.start(withForcedUpdate: true)
   }
   
   func start(withForcedUpdate forceUpdate: Bool = false) {
      
      // Conditions to update
      let lastUpdateIsLongerThanInterval = Globals().getSecondsFromISO8601DateString(network_lastUpdated ?? "") > network_updateInterval
      let savedNetworkDataIsEmpty = network_allRoutes.isEmpty || network_allStops.isEmpty
      let updateIsForcedByCaller = forceUpdate
      
      // Proceed if at least one condition is true
      if (lastUpdateIsLongerThanInterval || savedNetworkDataIsEmpty || updateIsForcedByCaller) {
         Task {
            await fetchStopsFromCarrisAPI()
            await fetchRoutesFromCarrisAPI()
         }
         // Replace timestamp in storage with current time
         let timestampOfCurrentUpdate = ISO8601DateFormatter().string(from: Date.now)
         UserDefaults.standard.set(timestampOfCurrentUpdate, forKey: network_storageKeyForLastUpdated)
      }
      
      
      // Retrieve favorites at app launch
      // self.retrieveFavorites()
      
   }
   
   
   
   
   
   /* * */
   /* MARK: - SECTION F: FETCH & FORMAT ROUTES FROM CARRIS API */
   /* This function first fetches the Routes List, which is an object */
   /* that contains all the available routes from the API. */
   /* The information for each Route is very short, so it is necessary to retrieve */
   /* the details for each route. Here, we only care about the publicy available routes. */
   /* After, for each route, it's details are formatted and transformed into a Route. */
   
   func fetchRoutesFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Routes_Sync_START)
      Appstate.shared.change(to: .loading, for: .routes)
      
      print("GB: Fetching Routes: Starting...")
      
      do {
         // Request API Routes List
         var requestCarrisAPIRoutesList = URLRequest(url: URL(string: "\(api_carrisEndpoint)/Routes")!)
         requestCarrisAPIRoutesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIRoutesList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIRoutesList.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIRoutesList, rawResponseCarrisAPIRoutesList) = try await URLSession.shared.data(for: requestCarrisAPIRoutesList)
         let responseCarrisAPIRoutesList = rawResponseCarrisAPIRoutesList as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIRoutesList?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.fetchRoutesFromCarrisAPI()
            return
         } else if (responseCarrisAPIRoutesList?.statusCode != 200) {
            print(responseCarrisAPIRoutesList as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedCarrisAPIRoutesList = try JSONDecoder().decode([APIRoutesList].self, from: rawDataCarrisAPIRoutesList)
         
         self.network_updateProgress = decodedCarrisAPIRoutesList.count
                  
         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllRoutes: [Route_NEW] = []
         
         // For each available route in the API,
         for availableRoute in decodedCarrisAPIRoutesList {
            
            if (availableRoute.isPublicVisible ?? false) {
               
               print("Route: \(String(describing: availableRoute.routeNumber)) starting...")
               
               // Request Route Detail for ‹routeNumber›
               var requestAPIRouteDetail = URLRequest(url: URL(string: "\(api_carrisEndpoint)/Routes/\(availableRoute.routeNumber ?? "invalid-route-number")")!)
               requestAPIRouteDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
               requestAPIRouteDetail.addValue("application/json", forHTTPHeaderField: "Accept")
               requestAPIRouteDetail.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
               let (rawDataAPIRouteDetail, rawResponseAPIRouteDetail) = try await URLSession.shared.data(for: requestAPIRouteDetail)
               let responseAPIRouteDetail = rawResponseAPIRouteDetail as? HTTPURLResponse
               
               // Check status of response
               if (responseAPIRouteDetail?.statusCode == 401) {
                  await CarrisAuthentication.shared.authenticate()
                  await self.fetchRoutesFromCarrisAPI()
                  return
               } else if (responseAPIRouteDetail?.statusCode != 200) {
                  print(responseAPIRouteDetail as Any)
                  throw Appstate.ModuleError.carris_unavailable
               }
            
               let decodedAPIRouteDetail = try JSONDecoder().decode(APIRoute.self, from: rawDataAPIRouteDetail)
               
               // Define a temporary variable to store formatted route variants
               var tempFormattedRouteVariants: [Variant_NEW] = []
               
               // For each variant in route,
               // check if it is currently active, format it
               // and append the result to the temporary variable.
               for apiRouteVariant in decodedAPIRouteDetail.variants ?? [] {
                  if (apiRouteVariant.isActive ?? false) {
                     tempFormattedRouteVariants.append(
                        formatRawRouteVariant(rawVariant: apiRouteVariant)
                     )
                  }
               }
               
               // Build the formatted route object
               let formattedRoute = Route_NEW(
                  number: decodedAPIRouteDetail.routeNumber ?? "-",
                  name: decodedAPIRouteDetail.name ?? "-",
                  kind: Globals().getKind(by: decodedAPIRouteDetail.routeNumber ?? "-"),
                  variants: tempFormattedRouteVariants
               )
               
               // Save the formatted route object in the allRoutes temporary variable
               tempAllRoutes.append(formattedRoute)
               
               self.network_updateProgress! -= 1
               
               print("Route: Route.\(String(describing: formattedRoute.number)) complete.")
               
               try await Task.sleep(nanoseconds: 100_000_000)
               
            }
            
         }
         
         // Finally, save the temporary variables into storage,
         // while removing the previous, old ones.
         self.network_allRoutes.removeAll()
         self.network_allRoutes.append(contentsOf: tempAllRoutes)
         if let encodedAllRoutes = try? JSONEncoder().encode(self.network_allRoutes) {
            UserDefaults.standard.set(encodedAllRoutes, forKey: network_storageKeyForSavedRoutes)
         }
         
         print("Fetching Routes: Complete!")
         
         Analytics.shared.capture(event: .Routes_Sync_OK)
         Appstate.shared.change(to: .idle, for: .routes)
         
      } catch {
         Analytics.shared.capture(event: .Routes_Sync_ERROR)
         Appstate.shared.change(to: .error, for: .routes)
         print("Fetching Routes: Error!")
         print(error)
         print("************")
      }
      
   }
   
   
   
   
   func formatConnections(rawConnections: [APIRouteVariantItineraryConnection]) -> [Connection_NEW] {
      
      var tempConnections: [Connection_NEW] = []
      
      // For each connection,
      // convert the nested objects into a simplified RouteStop object
      for rawConnection in rawConnections {
         
         // Append new values to the temporary variable property directly
         tempConnections.append(
            Connection_NEW(
               orderInRoute: rawConnection.orderNum ?? -1,
               stop: Stop_NEW(
                  publicId: rawConnection.busStop?.publicId ?? "-",
                  name: rawConnection.busStop?.name ?? "-",
                  lat: rawConnection.busStop?.lat ?? 0,
                  lng: rawConnection.busStop?.lng ?? 0
               )
            )
         )
         
      }
      
      // Sort the stops
      tempConnections.sort(by: { $0.orderInRoute < $1.orderInRoute })
      
      return tempConnections
      
   }
   
   
   /* MARK: - Format Route Variants */
   // Parse and simplify the data model for variants
   func formatRawRouteVariant(rawVariant: APIRouteVariant) -> Variant_NEW {
      
      // For each Itinerary type,
      // check if it is defined (not nil) in the raw object
      var tempItineraries: [Itinerary_NEW] = []
      
      // For UpItinerary:
      if (rawVariant.upItinerary != nil) {
         tempItineraries.append(
            Itinerary_NEW(
               direction: .ascending,
               connections: formatConnections(rawConnections: rawVariant.upItinerary!.connections ?? [])
            )
         )
      }
      
      // For DownItinerary:
      if (rawVariant.downItinerary != nil) {
         tempItineraries.append(
            Itinerary_NEW(
               direction: .descending,
               connections: formatConnections(rawConnections: rawVariant.downItinerary!.connections ?? [])
            )
         )
      }
      
      // For CircItinerary:
      if (rawVariant.circItinerary != nil) {
         tempItineraries.append(
            Itinerary_NEW(
               direction: .circular,
               connections: formatConnections(rawConnections: rawVariant.circItinerary!.connections ?? [])
            )
         )
      }
      
      
//      if (formattedVariant.isCircular) {
//         formattedVariant.name = getTerminalStopNameForVariant(variant: formattedVariant, direction: .circular)
//      } else {
//         let firstStop = getTerminalStopNameForVariant(variant: formattedVariant, direction: .ascending)
//         let lastStop = getTerminalStopNameForVariant(variant: formattedVariant, direction: .descending)
//         formattedVariant.name = "\(firstStop) ⇄ \(lastStop)"
//      }
      
      // Finally, return the temporary variable to the caller
      return Variant_NEW(
         number: rawVariant.variantNumber ?? -1,
         name: "in-progress",
         itineraries: tempItineraries
      )
      
   }
   
   
   /* MARK: - Get Terminal Stop Name for Variant */
   // This function returns the provided variant's terminal stop for the provided direction.
   func getTerminalStopNameForVariant(variant: Variant, direction: Direction) -> String {
      switch direction {
         case .circular:
            return variant.circItinerary?.first?.name ?? "-"
         case .ascending:
            return variant.upItinerary?.last?.name ?? (variant.upItinerary?.first?.name ?? "-")
         case .descending:
            return variant.downItinerary?.last?.name ?? (variant.downItinerary?.first?.name ?? "-")
      }
   }
   
   
   func fetchStopsFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Stops_Sync_START)
      Appstate.shared.change(to: .loading, for: .stops)
      
      print("Fetching Stops: Starting...")
      
      do {
         // Request API Routes List
         var requestCarrisAPIStopsList = URLRequest(url: URL(string: "\(api_carrisEndpoint)/busstops")!)
         requestCarrisAPIStopsList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIStopsList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIStopsList.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIStopsList, rawResponseCarrisAPIStopsList) = try await URLSession.shared.data(for: requestCarrisAPIStopsList)
         let responseCarrisAPIStopsList = rawResponseCarrisAPIStopsList as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIStopsList?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.fetchStopsFromCarrisAPI()
            return
         } else if (responseCarrisAPIStopsList?.statusCode != 200) {
            print(responseCarrisAPIStopsList as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedCarrisAPIStopsList = try JSONDecoder().decode([APIStop].self, from: rawDataCarrisAPIStopsList)
         
         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllStops: [Stop_NEW] = []
         
         // For each available route in the API,
         for availableStop in decodedCarrisAPIStopsList {
            if (availableStop.isPublicVisible ?? false) {
               // Save the formatted route object in the allRoutes temporary variable
               tempAllStops.append(
                  Stop_NEW(
                     publicId: availableStop.publicId ?? "0",
                     name: availableStop.name ?? "-",
                     lat: availableStop.lat ?? 0,
                     lng: availableStop.lng ?? 0
                  )
               )
            }
         }
         
         // Finally, save the temporary variables into storage,
         // while removing the previous, old ones.
         self.network_allStops.removeAll()
         self.network_allStops.append(contentsOf: tempAllStops)
         if let encodedAllStops = try? JSONEncoder().encode(self.network_allStops) {
            UserDefaults.standard.set(encodedAllStops, forKey: network_storageKeyForSavedStops)
         }
         
         print("[GB-Debug] Fetching Stops: Complete!")
         
         Analytics.shared.capture(event: .Stops_Sync_OK)
         Appstate.shared.change(to: .idle, for: .stops)
         
      } catch {
         Analytics.shared.capture(event: .Stops_Sync_ERROR)
         Appstate.shared.change(to: .error, for: .stops)
         print("Fetching Stops: Error!")
         print(error)
         print("************")
      }
      
   }
   
   /* MARK: - Find Route by RouteNumber */
   // This function searches for the provided routeNumber in all routes array,
   // and returns it if found. If not found, returns nil.
   func findRoute(by routeNumber: String) -> Route_NEW? {
      
      // Find index of route matching requested routeNumber
      let indexOfRouteInArray = network_allRoutes.firstIndex(where: { (route) -> Bool in
         route.number == routeNumber // test if this is the item we're looking for
      }) ?? nil // If the item does not exist, return default value nil
      
      // If a match is found...
      if (indexOfRouteInArray != nil) {
         return network_allRoutes[indexOfRouteInArray!]
      } else {
         return nil
      }
      
   }
   
   
   
   
   
   
   
   /* * */
   /* MARK: - SECTION B: SELECTORS */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia, */
   /* molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum */
   /* numquam blanditiis harum quisquam eius sed odit fugiat */
   
   // Routes
   
   public func select(route routeNumber: String) {
      if let route = self.findRoute(by: routeNumber) {
         self.select(route: route)
      }
   }
   
   func select(route routeNumber: String, returnResult: Bool) -> Bool {
      if let route = self.findRoute(by: routeNumber) {
         self.select(route: route)
         return true
      } else {
         return false
      }
   }
   
   private func select(route: Route_NEW) {
      self.network_selectedRoute = route
      self.select(variant: route.variants[0])
   }
   
   public func select(variant: Variant_NEW) {
      self.network_selectedVariant = variant
   }
   
   
   public func deselect() {
      self.network_selectedRoute = nil
      self.network_selectedVariant = nil
      self.network_selectedConnection = nil
      self.network_selectedStop = nil
   }
   
   
   // Stops
   
   private func select(stop: Stop_NEW) {
      self.network_selectedStop = stop
   }
   
   func select(stop stopPublicId: String) {
      let stop = self.findStop(by: stopPublicId)
      if (stop != nil) {
         self.select(stop: stop!)
      }
   }
   
   func select(stop stopPublicId: String, returnResult: Bool) -> Bool {
      let stop = self.findStop(by: stopPublicId)
      if (stop != nil) {
         self.select(stop: stop!)
         return true
      } else {
         return false
      }
   }
   
   
   /* MARK: - Find Stop by Public ID */
   // This function searches for the provided routeNumber in all routes array,
   // and returns it if found. If not found, returns nil.
   func findStop(by stopPublicId: String) -> Stop_NEW? {
      
      let parsedStopPublicId = Int(stopPublicId) ?? 0
      
      // Find index of route matching requested routeNumber
      let indexOfStopInArray = network_allStops.firstIndex(where: { (stop) -> Bool in
         stop.publicId == String(parsedStopPublicId) // test if this is the item we're looking for
      }) ?? nil // If the item does not exist, return default value -1
      
      // If a match is found...
      if (indexOfStopInArray != nil) {
         return network_allStops[indexOfStopInArray!]
      } else {
         return nil
      }
      
   }
   
   
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
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      do {
         // Request all Vehicles from API
         var requestCarrisAPIVehiclesList = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/vehicleStatuses")!) // /routeNumber/\(routeNumber!)
         requestCarrisAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIVehiclesList.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIVehiclesList, rawResponseCarrisAPIVehiclesList) = try await URLSession.shared.data(for: requestCarrisAPIVehiclesList)
         let responseCarrisAPIVehiclesList = rawResponseCarrisAPIVehiclesList as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIVehiclesList?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.fetchVehiclesListFromCarrisAPI_NEW()
            return
         } else if (responseCarrisAPIVehiclesList?.statusCode != 200) {
            print(responseCarrisAPIVehiclesList as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedCarrisAPIVehiclesList = try JSONDecoder().decode([CarrisAPIVehicleSummary].self, from: rawDataCarrisAPIVehiclesList)
         
         
         for vehicleSummary in decodedCarrisAPIVehiclesList {
            
            let indexOfVehicleInArray = self.network_allVehicles.firstIndex(where: {
               $0.id == vehicleSummary.busNumber
            })
            
            if (indexOfVehicleInArray != nil) {
               network_allVehicles[indexOfVehicleInArray!].routeNumber = vehicleSummary.routeNumber ?? "-"
               network_allVehicles[indexOfVehicleInArray!].kind = Globals().getKind(by: vehicleSummary.routeNumber ?? "-")
               network_allVehicles[indexOfVehicleInArray!].lat = vehicleSummary.lat ?? 0
               network_allVehicles[indexOfVehicleInArray!].lng = vehicleSummary.lng ?? 0
               network_allVehicles[indexOfVehicleInArray!].previousLatitude = vehicleSummary.previousLatitude ?? 0
               network_allVehicles[indexOfVehicleInArray!].previousLongitude = vehicleSummary.previousLongitude ?? 0
               network_allVehicles[indexOfVehicleInArray!].lastGpsTime = vehicleSummary.lastGpsTime ?? ""
               network_allVehicles[indexOfVehicleInArray!].angleInRadians = self.getAngleInRadians(
                  prevLat: vehicleSummary.previousLatitude ?? 0,
                  prevLng: vehicleSummary.previousLongitude ?? 0,
                  currLat: vehicleSummary.lat ?? 0,
                  currLng: vehicleSummary.lng ?? 0
               )
            } else {
               self.network_allVehicles.append(
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
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
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
      guard let indexOfVehicleInArray = network_allVehicles.firstIndex(where: { $0.id == busNumber }) else {
         return
      }
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestCarrisAPIVehicleDetail = URLRequest(url: URL(string: "\(api_carrisEndpoint)/SGO/busNumber/\(busNumber)")!)
         requestCarrisAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIVehicleDetail.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIVehicleDetail, rawResponseCarrisAPIVehicleDetail) = try await URLSession.shared.data(for: requestCarrisAPIVehicleDetail)
         let responseCarrisAPIVehicleDetail = rawResponseCarrisAPIVehicleDetail as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIVehicleDetail?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.fetchVehicleDetailsFromCarrisAPI_NEW(for: busNumber)
            return
         } else if (responseCarrisAPIVehicleDetail?.statusCode != 200) {
            print(responseCarrisAPIVehicleDetail as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedCarrisAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIVehicleDetail.self, from: rawDataCarrisAPIVehicleDetail)
         
         // Update details of Vehicle
         network_allVehicles[indexOfVehicleInArray].vehiclePlate = decodedCarrisAPIVehicleDetail.vehiclePlate ?? "-"
         network_allVehicles[indexOfVehicleInArray].lastStopOnVoyageName = decodedCarrisAPIVehicleDetail.lastStopOnVoyageName ?? "-"
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
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
      guard let indexOfVehicleInArray = network_allVehicles.firstIndex(where: { $0.id == busNumber }) else {
         return
      }
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestCommunityAPIVehicle = URLRequest(url: URL(string: "\(api_communityEndpoint)/estbus?busNumber=\(busNumber)")!)
         requestCommunityAPIVehicle.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCommunityAPIVehicle.addValue("application/json", forHTTPHeaderField: "Accept")
         let (rawDataCommunityAPIVehicle, rawResponseCommunityAPIVehicle) = try await URLSession.shared.data(for: requestCommunityAPIVehicle)
         let responseCommunityAPIVehicle = rawResponseCommunityAPIVehicle as? HTTPURLResponse
         
         // Check status of response
         if (responseCommunityAPIVehicle?.statusCode != 200) {
            print(responseCommunityAPIVehicle as Any)
            throw Appstate.ModuleError.community_unavailable
         }
         
         let decodedCommunityAPIVehicle = try JSONDecoder().decode([CommunityAPIVehicle].self, from: rawDataCommunityAPIVehicle)
         
         // Update details of Vehicle
         network_allVehicles[indexOfVehicleInArray].estimatedTimeofArrivalCorrected = decodedCommunityAPIVehicle[0].estimatedTimeofArrivalCorrected
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("GB: ERROR IN 'fetchVehicleFromCommunityAPI_NEW': \(error)")
         return
      }
      
   }
   
   
   
   
   
   func getVehicle(by busNumber: Int) -> Vehicle? {
      let indexInArray = self.network_allVehicles.firstIndex(where: {
         $0.busNumber == busNumber
      })
      
      if (indexInArray != nil) {
         return network_allVehicles[indexInArray!]
      } else {
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
