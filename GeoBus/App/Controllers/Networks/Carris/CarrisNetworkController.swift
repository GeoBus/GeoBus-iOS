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
   
   private let api_communityEndpoint: String = "https://api.carril.workers.dev"
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 2: PUBLISHED VARIABLES */
   /* Here are all the @Published variables that can be consumed by the app views. */
   /* It is important to keep the names of this variables short, but descriptive, */
   /* to avoid clutter on the interface code. */
   
   @Published var allRoutes: [Route_NEW] = []
   @Published var allStops: [Stop_NEW] = []
   @Published var allVehicles: [CarrisVehicle] = []
   
   @Published var lastUpdatedNetwork: String? = nil
   @Published var networkUpdateProgress: Int? = nil
   
   @Published var selectedRoute: Route_NEW? = nil
   @Published var selectedVariant: Variant_NEW? = nil
   @Published var selectedConnection: Connection_NEW? = nil
   @Published var selectedStop: Stop_NEW? = nil
   
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
            self.allStops = decodedSavedNetworkStops
         }
      }
      
      // Unwrap and Decode Routes from Storage
      if let unwrappedSavedNetworkRoutes = UserDefaults.standard.data(forKey: network_storageKeyForSavedRoutes) {
         if let decodedSavedNetworkRoutes = try? JSONDecoder().decode([Route_NEW].self, from: unwrappedSavedNetworkRoutes) {
            self.allRoutes = decodedSavedNetworkRoutes
         }
      }
      
      // Unwrap last timestamp from Storage
      if let unwrappedLastUpdatedNetwork = UserDefaults.standard.string(forKey: network_storageKeyForLastUpdated) {
         self.lastUpdatedNetwork = unwrappedLastUpdatedNetwork
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
      let lastUpdateIsLongerThanInterval = Helpers.getSecondsFromISO8601DateString(lastUpdatedNetwork ?? "") > network_updateInterval
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
         
         let decodedCarrisAPIRoutesList = try JSONDecoder().decode([APIRoutesList].self, from: rawDataCarrisAPIRoutesList)
         
         self.networkUpdateProgress = decodedCarrisAPIRoutesList.count
         
         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllRoutes: [Route_NEW] = []
         
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
         self.allStops.removeAll()
         self.allStops.append(contentsOf: tempAllStops)
         if let encodedAllStops = try? JSONEncoder().encode(self.allStops) {
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
   
   enum CarrisNetworkControllerSelectableObject {
      case route
      case variant
      case stop
   }
   
   public func isSelected(what selectableObject: CarrisNetworkControllerSelectableObject) -> Bool {
      switch selectableObject {
         case .route:
            return (self.selectedRoute != nil) ? true : false
         case .variant:
            return (self.selectedVariant != nil) ? true : false
         case .stop:
            return (self.selectedStop != nil) ? true : false
      }
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
   
   private func select(route: Route_NEW) {
      self.selectedRoute = route
      self.select(variant: route.variants[0])
   }
   
   public func select(variant: Variant_NEW) {
      self.selectedVariant = variant
   }
   
   
   public func deselect() {
      self.selectedRoute = nil
      self.selectedVariant = nil
      self.selectedConnection = nil
      self.selectedStop = nil
   }
   
   
   // Stops
   
   private func select(stop: Stop_NEW) {
      self.selectedStop = stop
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
   
   
   /* MARK: - UPDATE VEHICLES */
   
   // This function decides whether to update available routes
   
   func update() {
      
      Task {
         await fetchVehiclesListFromCarrisAPI_NEW()
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
         
         
         // Loop through all existing objects in the array
         for vehicleSummary in decodedCarrisAPIVehiclesList {
            
            // Check if vehicleSummary has an unique identifier
            if (vehicleSummary.busNumber != nil) {
               
               // If there is already and
               if let existingVehicleObject = self.allVehicles[withId: vehicleSummary.busNumber!] {
                  
                  existingVehicleObject.routeNumber = vehicleSummary.routeNumber ?? "-"
                  existingVehicleObject.lat = vehicleSummary.lat ?? 0
                  existingVehicleObject.lng = vehicleSummary.lng ?? 0
                  existingVehicleObject.previousLatitude = vehicleSummary.previousLatitude ?? 0
                  existingVehicleObject.previousLongitude = vehicleSummary.previousLongitude ?? 0
                  existingVehicleObject.lastGpsTime = vehicleSummary.lastGpsTime ?? ""
                  
               } else {
                  self.allVehicles.append(
                     CarrisVehicle(
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
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLES: \(error)")
         return
      }
      
   }
   
   
   
   
   
   
   
   func getVehicle(by busNumber: Int) -> CarrisVehicle? {
      if let existingVehicleObject = self.allVehicles[withId: busNumber] {
         return existingVehicleObject
      } else {
         return nil
      }
   }
   
   
   
}
