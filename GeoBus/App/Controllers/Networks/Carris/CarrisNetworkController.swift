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
   
   private let carrisNetworkUpdateInterval: Int = 86400 * 5 // 5 days
   
   private let storageKeyForLastUpdatedCarrisNetwork: String = "carris_lastUpdatedNetwork"
   private let storageKeyForSavedStops: String = "carris_savedStops"
   private let storageKeyForFavoriteStops: String = "carris_favoriteStops"
   private let storageKeyForSavedRoutes: String = "carris_savedRoutes"
   private let storageKeyForFavoriteRoutes: String = "carris_favoriteRoutes"
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 2: PUBLISHED VARIABLES */
   /* Here are all the @Published variables that can be consumed by the app views. */
   /* It is important to keep the names of this variables short, but descriptive, */
   /* to avoid clutter on the interface code. */
   
   @Published var lastUpdatedNetwork: String? = nil
   @Published var networkUpdateProgress: Int? = nil
   
   @Published var allRoutes: [CarrisNetworkModel.Route] = []
   @Published var allStops: [CarrisNetworkModel.Stop] = []
   @Published var allVehicles: [CarrisNetworkModel.Vehicle] = []
   
   @Published var activeRoute: CarrisNetworkModel.Route? = nil
   @Published var activeVariant: CarrisNetworkModel.Variant? = nil
   @Published var activeConnection: CarrisNetworkModel.Connection? = nil
   @Published var activeStop: CarrisNetworkModel.Stop? = nil
   @Published var activeVehicles: [CarrisNetworkModel.Vehicle] = []
   
   @Published var favorites_routes: [CarrisNetworkModel.Route] = []
   @Published var favorites_stops: [CarrisNetworkModel.Stop] = []
   
   
   
   /* * */
   /* MARK: - SECTION 3: INITIALIZER */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. Do not call other */
   /* functions yet because Appstate and Authentication must be passed first. */
   
   static let shared = CarrisNetworkController()
   
   
   
   /* * */
   /* MARK: - SECTION 3: INITIALIZER */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. Do not call other */
   /* functions yet because Appstate and Authentication must be passed first. */
   
   private init() {
      
      // Unwrap and Decode Stops from Storage
      if let unwrappedSavedNetworkStops = UserDefaults.standard.data(forKey: storageKeyForSavedStops) {
         if let decodedSavedNetworkStops = try? JSONDecoder().decode([CarrisNetworkModel.Stop].self, from: unwrappedSavedNetworkStops) {
            self.allStops = decodedSavedNetworkStops
         }
      }
      
      // Unwrap and Decode Routes from Storage
      if let unwrappedSavedNetworkRoutes = UserDefaults.standard.data(forKey: storageKeyForSavedRoutes) {
         if let decodedSavedNetworkRoutes = try? JSONDecoder().decode([CarrisNetworkModel.Route].self, from: unwrappedSavedNetworkRoutes) {
            self.allRoutes = decodedSavedNetworkRoutes
         }
      }
      
      // Unwrap last timestamp from Storage
      if let unwrappedLastUpdatedNetwork = UserDefaults.standard.string(forKey: storageKeyForLastUpdatedCarrisNetwork) {
         self.lastUpdatedNetwork = unwrappedLastUpdatedNetwork
      }
      
   }
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 5: UPDATE NETWORK FROM CARRIS API */
   /* This function decides whether to update the complete network model */
   /* if it is considered outdated or is inexistent on device storage. */
   /* Provide a convenience method to allow user-requested updates from the UI. */
   
   public func start() {
      self.updateNetwork(resetAndUpdate: false)
      self.updateVehicles()
   }
   
   public func resetAndUpdateNetwork() {
      self.updateNetwork(resetAndUpdate: true)
   }
   
   private func updateNetwork(resetAndUpdate forceUpdate: Bool) {
      
      // Conditions to update
      let lastUpdateIsLongerThanInterval = Helpers.getSecondsFromISO8601DateString(lastUpdatedNetwork ?? "") > carrisNetworkUpdateInterval
      let savedNetworkDataIsEmpty = allRoutes.isEmpty || allStops.isEmpty
      let updateIsForcedByCaller = forceUpdate
      
      // Proceed if at least one condition is true
      if (lastUpdateIsLongerThanInterval || savedNetworkDataIsEmpty || updateIsForcedByCaller) {
         Task {
            await fetchStopsFromCarrisAPI()
            await fetchRoutesFromCarrisAPI()
         }
         // Replace timestamp in storage with current time
         let timestampOfCurrentUpdate = ISO8601DateFormatter().string(from: Date.now)
         UserDefaults.standard.set(timestampOfCurrentUpdate, forKey: storageKeyForLastUpdatedCarrisNetwork)
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
         var requestCarrisAPIRoutesList = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/Routes")!)
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
         
         let decodedCarrisAPIRoutesList = try JSONDecoder().decode([CarrisAPIModel.RoutesList].self, from: rawDataCarrisAPIRoutesList)
         
         self.networkUpdateProgress = decodedCarrisAPIRoutesList.count
         
         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllRoutes: [CarrisNetworkModel.Route] = []
         
         // For each available route in the API,
         for availableRoute in decodedCarrisAPIRoutesList {
            
            if (availableRoute.isPublicVisible ?? false) {
               
               print("Route: \(String(describing: availableRoute.routeNumber)) starting...")
               
               // Request Route Detail for ‹routeNumber›
               var requestAPIRouteDetail = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/Routes/\(availableRoute.routeNumber ?? "invalid-route-number")")!)
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
               
               let decodedAPIRouteDetail = try JSONDecoder().decode(CarrisAPIModel.Route.self, from: rawDataAPIRouteDetail)
               
               // Define a temporary variable to store formatted route variants
               var tempFormattedRouteVariants: [CarrisNetworkModel.Variant] = []
               
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
               let formattedRoute = CarrisNetworkModel.Route(
                  number: decodedAPIRouteDetail.routeNumber ?? "-",
                  name: decodedAPIRouteDetail.name ?? "-",
                  kind: Helpers.getKind(by: decodedAPIRouteDetail.routeNumber ?? "-"),
                  variants: tempFormattedRouteVariants
               )
               
               // Save the formatted route object in the allRoutes temporary variable
               tempAllRoutes.append(formattedRoute)
               
               self.networkUpdateProgress! -= 1
               
               print("Route: Route.\(String(describing: formattedRoute.number)) complete.")
               
               try await Task.sleep(nanoseconds: 100_000_000)
               
            }
            
         }
         
         // Finally, save the temporary variables into storage,
         // while removing the previous, old ones.
         self.allRoutes.removeAll()
         self.allRoutes.append(contentsOf: tempAllRoutes)
         if let encodedAllRoutes = try? JSONEncoder().encode(self.allRoutes) {
            UserDefaults.standard.set(encodedAllRoutes, forKey: storageKeyForSavedRoutes)
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
   
   
   
   
   func formatConnections(rawConnections: [CarrisAPIModel.Connection]) -> [CarrisNetworkModel.Connection] {
      
      var tempConnections: [CarrisNetworkModel.Connection] = []
      
      // For each connection,
      // convert the nested objects into a simplified RouteStop object
      for rawConnection in rawConnections {
         
         // Append new values to the temporary variable property directly
         tempConnections.append(
            CarrisNetworkModel.Connection(
               orderInRoute: rawConnection.orderNum ?? -1,
               stop: CarrisNetworkModel.Stop(
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
   func formatRawRouteVariant(rawVariant: CarrisAPIModel.Variant) -> CarrisNetworkModel.Variant {
      
      // For each Itinerary type,
      // check if it is defined (not nil) in the raw object
      var tempItineraries: [CarrisNetworkModel.Itinerary] = []
      
      // For UpItinerary:
      if (rawVariant.upItinerary != nil) {
         tempItineraries.append(
            CarrisNetworkModel.Itinerary(
               direction: .ascending,
               connections: formatConnections(rawConnections: rawVariant.upItinerary!.connections ?? [])
            )
         )
      }
      
      // For DownItinerary:
      if (rawVariant.downItinerary != nil) {
         tempItineraries.append(
            CarrisNetworkModel.Itinerary(
               direction: .descending,
               connections: formatConnections(rawConnections: rawVariant.downItinerary!.connections ?? [])
            )
         )
      }
      
      // For CircItinerary:
      if (rawVariant.circItinerary != nil) {
         tempItineraries.append(
            CarrisNetworkModel.Itinerary(
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
      return CarrisNetworkModel.Variant(
         number: rawVariant.variantNumber ?? -1,
         name: "in-progress",
         itineraries: tempItineraries
      )
      
   }
   
   
   /* MARK: - Get Terminal Stop Name for Variant */
   // This function returns the provided variant's terminal stop for the provided direction.
   func getTerminalStopNameForVariant(variant: CarrisNetworkModel.Variant, direction: CarrisNetworkModel.Direction) -> String {
//      switch direction {
//         case .circular:
//            return variant.circItinerary?.first?.name ?? "-"
//         case .ascending:
//            return variant.upItinerary?.last?.name ?? (variant.upItinerary?.first?.name ?? "-")
//         case .descending:
//            return variant.downItinerary?.last?.name ?? (variant.downItinerary?.first?.name ?? "-")
//      }
      return "not implemented"
   }
   
   
   func fetchStopsFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Stops_Sync_START)
      Appstate.shared.change(to: .loading, for: .stops)
      
      print("Fetching Stops: Starting...")
      
      do {
         // Request API Routes List
         var requestCarrisAPIStopsList = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/busstops")!)
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
         
         let decodedCarrisAPIStopsList = try JSONDecoder().decode([CarrisAPIModel.Stop].self, from: rawDataCarrisAPIStopsList)
         
         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllStops: [CarrisNetworkModel.Stop] = []
         
         // For each available route in the API,
         for availableStop in decodedCarrisAPIStopsList {
            if (availableStop.isPublicVisible ?? false) {
               // Save the formatted route object in the allRoutes temporary variable
               tempAllStops.append(
                  CarrisNetworkModel.Stop(
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
         self.allStops.removeAll()
         self.allStops.append(contentsOf: tempAllStops)
         if let encodedAllStops = try? JSONEncoder().encode(self.allStops) {
            UserDefaults.standard.set(encodedAllStops, forKey: storageKeyForSavedStops)
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
   func findRoute(by routeNumber: String) -> CarrisNetworkModel.Route? {
      if let requestedRouteObject = self.allRoutes[withId: routeNumber] {
         return requestedRouteObject
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
   
   
   private func select(route: CarrisNetworkModel.Route) {
      self.activeRoute = route
      self.select(variant: route.variants[0])
      self.activeStop = nil
      self.activeConnection = nil
      self.getActiveVehicles()
   }
   
   
   
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
   
   
   
   public func select(variant: CarrisNetworkModel.Variant) {
      self.activeVariant = variant
   }
   
   
   public func deselect() {
      self.activeRoute = nil
      self.activeVariant = nil
      self.activeConnection = nil
      self.activeStop = nil
   }
   
   
   // Stops
   
   private func select(stop: CarrisNetworkModel.Stop) {
      self.activeStop = stop
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
   func findStop(by stopPublicId: String) -> CarrisNetworkModel.Stop? {
      
      let parsedStopPublicId = Int(stopPublicId) ?? 0
      
      // Find index of route matching requested routeNumber
      let indexOfStopInArray = allStops.firstIndex(where: { (stop) -> Bool in
         stop.publicId == String(parsedStopPublicId) // test if this is the item we're looking for
      }) ?? nil // If the item does not exist, return default value -1
      
      // If a match is found...
      if (indexOfStopInArray != nil) {
         return allStops[indexOfStopInArray!]
      } else {
         return nil
      }
      
   }
   
   
   
   
   
   
   
   func getActiveVehicles() {
      if (activeRoute != nil) {
         
         self.activeVehicles.removeAll()
         
         // Filter Vehicles matching the required conditions:
         for vehicle in self.allVehicles {
            
            // CONDITION 1:
            // Vehicle is currently driving the requested routeNumber
            let matchesSelectedRouteNumber = vehicle.routeNumber == activeRoute?.number
            
            // CONDITION 2:
            // Vehicle was last seen no longer than 3 minutes
            let isNotZombieVehicle = true // Helpers.getLastSeenTime(since: vehicle.lastGpsTime ?? "") < 180
            
            // Find index of Annotation matching this vehicle busNumber
            if (matchesSelectedRouteNumber && isNotZombieVehicle) {
               self.activeVehicles.append(vehicle)
            }
            
         }
         
      }
      
   }
   
   
   
   func updateVehicles() {
      Task {
         await fetchVehiclesListFromCarrisAPI()
         self.getActiveVehicles()
      }
   }
   
   
   
   /* MARK: - FETCH VEHICLES SUMMARY FROM CARRIS API */
   
   // This function calls the GeoBus API and receives vehicle metadata,
   // including positions, for the set route number, while storing them
   // in the vehicles array. It also formats VehicleAnnotations and stores
   // them in the annotations array. It must have @objc flag because Timer
   // is written in Objective-C.
   
   func fetchVehiclesListFromCarrisAPI() async {
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      do {
         // Request all Vehicles from API
         var requestCarrisAPIVehiclesList = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/vehicleStatuses")!)
         requestCarrisAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIVehiclesList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIVehiclesList.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIVehiclesList, rawResponseCarrisAPIVehiclesList) = try await URLSession.shared.data(for: requestCarrisAPIVehiclesList)
         let responseCarrisAPIVehiclesList = rawResponseCarrisAPIVehiclesList as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIVehiclesList?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.fetchVehiclesListFromCarrisAPI()
            return
         } else if (responseCarrisAPIVehiclesList?.statusCode != 200) {
            print(responseCarrisAPIVehiclesList as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedCarrisAPIVehiclesList = try JSONDecoder().decode([CarrisAPIModel.VehicleSummary].self, from: rawDataCarrisAPIVehiclesList)
         
         
         // Loop through all existing objects in the array
         for vehicleSummary in decodedCarrisAPIVehiclesList {
            
            // Check if vehicleSummary has an unique identifier
            if (vehicleSummary.busNumber != nil) {
               
               let indexOfVehicleInArray = allVehicles.firstIndex(where: {
                  $0.id == vehicleSummary.busNumber
               })
               
               
               if (indexOfVehicleInArray != nil) {
                  
                  allVehicles[indexOfVehicleInArray!].routeNumber = vehicleSummary.routeNumber ?? "-"
                  allVehicles[indexOfVehicleInArray!].lat = vehicleSummary.lat ?? 0
                  allVehicles[indexOfVehicleInArray!].lng = vehicleSummary.lng ?? 0
                  allVehicles[indexOfVehicleInArray!].previousLatitude = vehicleSummary.previousLatitude ?? 0
                  allVehicles[indexOfVehicleInArray!].previousLongitude = vehicleSummary.previousLongitude ?? 0
                  allVehicles[indexOfVehicleInArray!].lastGpsTime = vehicleSummary.lastGpsTime ?? ""
                  
               } else {
                  self.allVehicles.append(
                     CarrisNetworkModel.Vehicle(
                        id: vehicleSummary.busNumber ?? 0,
                        routeNumber: vehicleSummary.routeNumber ?? "-",
                        lat: vehicleSummary.lat ?? 0,
                        lng: vehicleSummary.lng ?? 0,
                        previousLatitude: vehicleSummary.previousLatitude ?? 0,
                        previousLongitude: vehicleSummary.previousLongitude ?? 0,
                        lastGpsTime: vehicleSummary.lastGpsTime ?? ""
                     )
                  )
               }
               
            }
            
         }
         
         print("GB6: allVehicles[0].lat: \(allVehicles[6].lat)")
         print("GB6: allVehicles[0].coordinate: \(allVehicles[6].coordinate)")
         
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLES: \(error)")
         return
      }
      
   }
   
   
   
   
   
   
   
   func getVehicle(by busNumber: Int) -> CarrisNetworkModel.Vehicle? {
      if let existingVehicleObject = self.allVehicles[withId: busNumber] {
         return existingVehicleObject
      } else {
         return nil
      }
   }
   
   
   
}
