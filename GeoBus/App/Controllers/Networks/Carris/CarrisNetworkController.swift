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
   
   private let secondsToConsiderVehicleAsStale: Int = 180 // 3 minutes
   
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
   /* MARK: - SECTION 3: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   static let shared = CarrisNetworkController()
   
   
   
   /* * */
   /* MARK: - SECTION 4: INITIALIZER */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. After this, check if */
   /* this stored data needs an update or not. */
   
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
      
      // Check if network needs an update
      self.update(reset: false)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 5.1: UPDATE NETWORK FROM CARRIS API */
   /* This function decides whether to update the complete network model */
   /* if it is considered outdated or is inexistent on device storage. */
   /* Provide a convenience method to allow user-requested updates from the UI. */
   
   public func resetAndUpdateNetwork() {
      self.update(reset: true)
   }
   
   private func update(reset forceUpdate: Bool) {
      
      // Conditions to update
      let lastUpdateIsLongerThanInterval = Helpers.getSecondsFromISO8601DateString(self.lastUpdatedNetwork ?? "") > self.carrisNetworkUpdateInterval
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
      
      // Update vehicles and favorites
      self.refresh()
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 5.2: REFRESH DATA */
   /* This function initiates vehicles refresh from Carris API, updates the ‹activeVehicles› array */
   /* and syncronizes favorites with iCloud, to ensure changes are always up to date. */
   
   public func refresh() {
      Task {
         await self.fetchVehiclesListFromCarrisAPI()
         self.populateActiveVehicles()
         self.retrieveFavoritesFromKVS()
      }
   }
   
   
   
   /* * */
   /* MARK: - SECTION 6: FETCH & FORMAT STOPS FROM CARRIS API */
   /* Call Carris API and retrieve all stops. Format them to the app model. */
   
   private func fetchStopsFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Stops_Sync_START)
      Appstate.shared.change(to: .loading, for: .stops)
      
      print("GB Carris: Fetching Stops: Starting...")
      
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
                     id: availableStop.id ?? -1,
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
         
         print("GB Carris: Fetching Stops: Complete!")
         
         Analytics.shared.capture(event: .Stops_Sync_OK)
         Appstate.shared.change(to: .idle, for: .stops)
         
      } catch {
         Analytics.shared.capture(event: .Stops_Sync_ERROR)
         Appstate.shared.change(to: .error, for: .stops)
         print("GB Carris: Fetching Stops: Error!")
         print(error)
         print("************")
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 7: FETCH & FORMAT ROUTES FROM CARRIS API */
   /* This function first fetches the Routes List from Carris API, */
   /* which is an object that contains all the available routes. */
   /* The information for each Route is very short, so it is necessary to retrieve */
   /* the details for each route. Here, we only care about the publicy available routes. */
   /* After, for each route, its details are formatted and transformed into a Route. */
   
   private func fetchRoutesFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Routes_Sync_START)
      Appstate.shared.change(to: .loading, for: .routes)
      
      print("GB Carris: Fetching Routes: Starting...")
      
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
               
               print("GB Carris: Route: \(String(describing: availableRoute.routeNumber)) starting...")
               
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
               
               print("GB Carris: Route: Route.\(String(describing: formattedRoute.number)) complete.")
               
               // Wait a moment before the next API request
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
         
         print("GB Carris: Fetching Routes: Complete!")
         
         Analytics.shared.capture(event: .Routes_Sync_OK)
         Appstate.shared.change(to: .idle, for: .routes)
         
      } catch {
         Analytics.shared.capture(event: .Routes_Sync_ERROR)
         Appstate.shared.change(to: .error, for: .routes)
         print("GB Carris: Fetching Routes: Error!")
         print(error)
         print("************")
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 7.1: FORMAT CARRIS ROUTE VARIANTS */
   /* Parse and simplify the data model for variants. Variants contain */
   /* one or more itineraries, each with a direction. Each itinerary is composed */
   /* of a series of connections, in which each contains a stop. */
   
   private func formatRawRouteVariant(rawVariant: CarrisAPIModel.Variant) -> CarrisNetworkModel.Variant {
      
      // For each Itinerary type, check if it is defined (not nil) in the raw object
      
      var tempVariantName: String = ""
      var tempCircularConnections: [CarrisNetworkModel.Connection]? = nil
      var tempAscendingConnections: [CarrisNetworkModel.Connection]? = nil
      var tempDescendingConnections: [CarrisNetworkModel.Connection]? = nil
      
      
      // . For CircItinerary:
      if (rawVariant.circItinerary != nil) {
         // If variant has circular itinerary, then it is circular
         tempCircularConnections = formatConnections(direction: .circular, rawConnections: rawVariant.circItinerary!.connections ?? [])
         tempVariantName = tempCircularConnections?.first?.stop.name ?? "-"
         
      } else {
         // If variant does not have circular itinerary, then it is regular ascending‹›descending,
         // but it still can have only one of these, so check for that.
         if (rawVariant.upItinerary != nil) {
            tempAscendingConnections = formatConnections(direction: .ascending, rawConnections: rawVariant.upItinerary!.connections ?? [])
            tempVariantName = tempAscendingConnections?.first?.stop.name ?? "-"
         }
         
         if (rawVariant.upItinerary != nil && rawVariant.downItinerary != nil) {
            tempVariantName += " ⇄ "
         }
         
         if (rawVariant.downItinerary != nil) {
            tempDescendingConnections = formatConnections(direction: .descending, rawConnections: rawVariant.downItinerary!.connections ?? [])
            tempVariantName += tempDescendingConnections?.first?.stop.name ?? "-"
         }
         
      }
      
      
      // 6. Finally, return the formatted variant to the caller
      return CarrisNetworkModel.Variant(
         number: rawVariant.variantNumber ?? -1,
         name: tempVariantName,
         circularItinerary: tempCircularConnections,
         ascendingItinerary: tempAscendingConnections,
         descendingItinerary: tempDescendingConnections
      )
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 7.2: FORMAT CARRIS CONNECTIONS */
   /* Each itinerary is composed of a series of connections, in which each */
   /* has a single stop. Connections contain the property ‹orderInRoute›. */
   
   private func formatConnections(direction: CarrisNetworkModel.Direction, rawConnections: [CarrisAPIModel.Connection]) -> [CarrisNetworkModel.Connection] {
      
      var tempConnections: [CarrisNetworkModel.Connection] = []
      
      for rawConnection in rawConnections {
         tempConnections.append(
            CarrisNetworkModel.Connection(
               direction: direction,
               orderInRoute: rawConnection.orderNum ?? -1,
               stop: CarrisNetworkModel.Stop(
                  id: rawConnection.busStop?.id ?? -1,
                  name: rawConnection.busStop?.name ?? "-",
                  lat: rawConnection.busStop?.lat ?? 0,
                  lng: rawConnection.busStop?.lng ?? 0
               )
            )
         )
      }
      
      // Sort the connections
      tempConnections.sort(by: { $0.orderInRoute < $1.orderInRoute })
      
      return tempConnections
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8.1: RETRIEVE FAVORITES FROM ICLOUD KVS */
   /* This function retrieves favorites from iCloud Key-Value-Storage. */
   
   private func retrieveFavoritesFromKVS() {
      
      // Initialize iCloud KVS
      let iCloudKeyValueStorage = NSUbiquitousKeyValueStore()
      iCloudKeyValueStorage.synchronize()
      
      // Get stored contents
      let savedFavoriteRoutes = iCloudKeyValueStorage.array(forKey: storageKeyForFavoriteRoutes) as? [String] ?? []
      let savedFavoriteStops = iCloudKeyValueStorage.array(forKey: storageKeyForFavoriteStops) as? [Int] ?? []
      
      // For Routes:
      self.favorites_routes.removeAll()
      for routeNumber in savedFavoriteRoutes {
         if let route = find(route: routeNumber) {
            self.favorites_routes.append(route)
         }
      }
      
      // For Stops:
      self.favorites_stops.removeAll()
      for stopId in savedFavoriteStops {
         if let stop = find(stop: stopId) {
            self.favorites_stops.append(stop)
         }
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8.2: SAVE FAVORITES TO ICLOUD KVS */
   /* This function saves a representation of the objects stored in the favorites arrays */
   /* to iCloud Key-Value-Store. This function should be called whenever a change */
   /* in favorites occurs, to ensure consistency across devices. */
   
   private func saveFavoritesToKVS() {
      
      // For Routes
      var favoriteRoutesToSave: [String] = []
      for favRoute in favorites_routes {
         favoriteRoutesToSave.append(favRoute.number)
      }
      
      // For Stops
      var favoriteStopsToSave: [Int] = []
      for favStop in favorites_stops {
         favoriteStopsToSave.append(favStop.id)
      }
      
      // Initialize iCloud KVS
      let iCloudKeyValueStorage = NSUbiquitousKeyValueStore()
      iCloudKeyValueStorage.set(favoriteRoutesToSave, forKey: storageKeyForFavoriteRoutes)
      iCloudKeyValueStorage.set(favoriteStopsToSave, forKey: storageKeyForFavoriteStops)
      iCloudKeyValueStorage.synchronize()
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8.3: TOGGLE ROUTES AND STOPS AS FAVORITES */
   /* These functions mark an object as favorite if it is not, and remove it from favorites if it is. */
   
   public func toggleFavorite(route: CarrisNetworkModel.Route) {
      if let index = self.favorites_routes.firstIndex(of: route) {
         self.favorites_routes.remove(at: index)
         Analytics.shared.capture(event: .Routes_Details_RemoveFromFavorites, properties: ["routeNumber": route.number])
      } else {
         self.favorites_routes.append(route)
         Analytics.shared.capture(event: .Routes_Details_AddToFavorites, properties: ["routeNumber": route.number])
      }
      saveFavoritesToKVS()
   }
   
   public func toggleFavoriteForActiveRoute() {
      if (self.activeRoute != nil) {
         self.toggleFavorite(route: self.activeRoute!)
      }
   }
   
   
   public func toggleFavorite(stop: CarrisNetworkModel.Stop) {
      if let index = self.favorites_stops.firstIndex(of: stop) {
         self.favorites_stops.remove(at: index)
         Analytics.shared.capture(event: .Routes_Details_RemoveFromFavorites, properties: ["stopId": stop.id])
      } else {
         self.favorites_stops.append(stop)
         Analytics.shared.capture(event: .Routes_Details_AddToFavorites, properties: ["stopId": stop.id])
      }
      saveFavoritesToKVS()
   }
   
   public func toggleFavoriteForActiveStop() {
      if (self.activeStop != nil) {
         self.toggleFavorite(stop: self.activeStop!)
      }
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8.4: IS FAVORITE CHECKER */
   /* These functions check if an object is marked as favorite. */
   
   public func isFavourite(route: CarrisNetworkModel.Route?) -> Bool {
      if (route != nil) {
         return self.favorites_routes.contains(route!)
      } else {
         return false
      }
   }
   
   public func isActiveRouteFavourite() -> Bool {
      return self.isFavourite(route: self.activeRoute)
   }
   
   
   public func isFavourite(stop: CarrisNetworkModel.Stop?) -> Bool {
      if (stop != nil) {
         return self.favorites_stops.contains(stop!)
      } else {
         return false
      }
   }
   
   public func isActiveStopFavourite() -> Bool {
      return self.isFavourite(stop: self.activeStop)
   }
   
   
   
   /* * */
   /* MARK: - SECTION 9: FIND OBJECTS BY IDENTIFIER */
   /* These functions search for the provided object identifier in the storage arrays */
   /* and return it if found or nil if not found. */
   
   private func find(route routeNumber: String) -> CarrisNetworkModel.Route? {
      if let requestedRouteObject = self.allRoutes[withId: routeNumber] {
         return requestedRouteObject
      } else {
         return nil
      }
   }
   
   private func find(stop stopId: Int) -> CarrisNetworkModel.Stop? {
      if let requestedStopObject = self.allStops[withId: stopId] {
         return requestedStopObject
      } else {
         return nil
      }
   }
   
   private func find(vehicle vehicleId: Int) -> CarrisNetworkModel.Vehicle? {
      if let requestedVehicleObject = self.allVehicles[withId: vehicleId] {
         return requestedVehicleObject
      } else {
         return nil
      }
   }
   
   
   
   /* * */
   /* MARK: - SECTION 10: OBJECT SELECTORS */
   /* These functions select and deselect the currently active objects. */
   /* Provide public functions to more easily select object by their identifier. */
   
   private func deselect() {
      self.activeRoute = nil
      self.activeVariant = nil
      self.activeConnection = nil
      self.activeStop = nil
      self.activeVehicles = []
   }
   
   
   private func select(route: CarrisNetworkModel.Route) {
      self.deselect()
      self.activeRoute = route
      self.select(variant: route.variants[0])
      self.populateActiveVehicles()
   }
   
   public func select(route routeNumber: String) -> Bool {
      if let route = self.find(route: routeNumber) {
         self.select(route: route)
         return true
      } else {
         return false
      }
   }
   
   
   public func select(variant: CarrisNetworkModel.Variant) {
      self.activeVariant = variant
   }
   
   
   private func select(connection: CarrisNetworkModel.Connection) {
      self.deselect()
      self.activeConnection = connection
   }
   
   
   private func select(stop: CarrisNetworkModel.Stop) {
      self.deselect()
      self.activeStop = stop
   }
   
   public func select(stop stopId: Int) -> Bool {
      let stop = self.find(stop: stopId)
      if (stop != nil) {
         self.select(stop: stop!)
         return true
      } else {
         return false
      }
   }
   
   
   
   /* * */
   /* MARK: - SECTION 11: SET ACTIVE VEHICLES */
   /* This function compares the currently active route number with all vehicles */
   /* appending the ones that match to the ‹activeVehicles› array. It also checks */
   /* if vehicles have an up-to-date location. */
   
   func populateActiveVehicles() {
      
      if (activeRoute != nil) {
         
         self.activeVehicles.removeAll()
         
         // Filter Vehicles matching the required conditions:
         for vehicle in self.allVehicles {
            
            // CONDITION 1:
            // Vehicle is currently driving the requested routeNumber
            let matchesSelectedRouteNumber = vehicle.routeNumber == activeRoute?.number
            
            // CONDITION 2:
            // Vehicle was last seen no longer than X minutes
            let isNotZombieVehicle = Helpers.getLastSeenTime(since: vehicle.lastGpsTime ?? "") < secondsToConsiderVehicleAsStale
            
            // Find index of Annotation matching this vehicle busNumber
            if (matchesSelectedRouteNumber && isNotZombieVehicle) {
               self.activeVehicles.append(vehicle)
            }
            
         }
         
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 12: FETCH ALL VEHICLES FROM CARRIS API */
   /* This function calls the Carris API and receives vehicle metadata, */
   /* including positions, for all currently active vehicles, */
   /* and stores them in the ‹allVehicles› array. */
   
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
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("GB Carris: Vehicles List: ERROR IN VEHICLES: \(error)")
         return
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 12: FETCH VEHICLE DETAILS FROM CARRIS API */
   /* This function calls the Carris API SGO endpoint to retrieve additional vehicle metadata, */
   /* such as location, license plate number and last stop on the current trip. Provide a convenience */
   /* function to allow the UI to request this information only when necessary. After retrieving the new details */
   /* fromt the API, re-populate the activeVehicles array to trigger an update in the UI. */
   
   public func getAdditionalDetailsFor(vehicle vehicleId: Int) {
      Task {
         await self.fetchVehicleDetailsFromCarrisAPI(for: vehicleId)
         self.populateActiveVehicles()
      }
   }
   
   private func fetchVehicleDetailsFromCarrisAPI(for vehicleId: Int) async {
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestCarrisAPIVehicleDetail = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/SGO/busNumber/\(vehicleId)")!)
         requestCarrisAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIVehicleDetail.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIVehicleDetail, rawResponseCarrisAPIVehicleDetail) = try await URLSession.shared.data(for: requestCarrisAPIVehicleDetail)
         let responseCarrisAPIVehicleDetail = rawResponseCarrisAPIVehicleDetail as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIVehicleDetail?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.fetchVehicleDetailsFromCarrisAPI(for: vehicleId)
            return
         } else if (responseCarrisAPIVehicleDetail?.statusCode != 200) {
            print(responseCarrisAPIVehicleDetail as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         
         let decodedCarrisAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIModel.VehicleDetail.self, from: rawDataCarrisAPIVehicleDetail)
         
         
         let indexOfVehicleInArray = allVehicles.firstIndex(where: {
            $0.id == vehicleId
         })
         
         if (indexOfVehicleInArray != nil) {
            allVehicles[indexOfVehicleInArray!].lat = decodedCarrisAPIVehicleDetail.lat
            allVehicles[indexOfVehicleInArray!].lng = decodedCarrisAPIVehicleDetail.lng
            allVehicles[indexOfVehicleInArray!].vehiclePlate = decodedCarrisAPIVehicleDetail.vehiclePlate
            allVehicles[indexOfVehicleInArray!].lastStopOnVoyageId = decodedCarrisAPIVehicleDetail.lastStopOnVoyageId
            allVehicles[indexOfVehicleInArray!].lastStopOnVoyageName = decodedCarrisAPIVehicleDetail.lastStopOnVoyageName
         }
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("GB Carris: Vehicle Details: ERROR IN VEHICLE DETAILS: \(error)")
         return
      }
      
   }
   
   
   
   /* MARK: - Get Estimations */
   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.
   
   public func getEstimation(for stopId: Int) async -> [CarrisNetworkModel.Estimation] {
         return await self.fetchEstimationsFromCarrisAPI(for: stopId)
//         self.populateActiveVehicles()
   }
   
   public func fetchEstimationsFromCarrisAPI(for stopId: Int) async -> [CarrisNetworkModel.Estimation] {
      
      Appstate.shared.change(to: .loading, for: .estimations)
      
      do {
         // Request API Routes List
         var requestCarrisAPIEstimations = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/Estimations/busStop/\(stopId)/top/5")!)
         requestCarrisAPIEstimations.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestCarrisAPIEstimations.addValue("application/json", forHTTPHeaderField: "Accept")
         requestCarrisAPIEstimations.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataCarrisAPIEstimations, rawResponseCarrisAPIEstimations) = try await URLSession.shared.data(for: requestCarrisAPIEstimations)
         let responseCarrisAPIEstimations = rawResponseCarrisAPIEstimations as? HTTPURLResponse
         
         // Check status of response
         if (responseCarrisAPIEstimations?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            return await self.fetchEstimationsFromCarrisAPI(for: stopId)
         } else if (responseCarrisAPIEstimations?.statusCode != 200) {
            print(responseCarrisAPIEstimations as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedCarrisAPIEstimations = try JSONDecoder().decode([CarrisAPIModel.Estimation].self, from: rawDataCarrisAPIEstimations)
         
         
         var tempFormattedEstimations: [CarrisNetworkModel.Estimation] = []
         
         
         // For each available vehicles in the API
         for apiEstimation in decodedCarrisAPIEstimations {
            tempFormattedEstimations.append(
               CarrisNetworkModel.Estimation(
                  stopId: Int(apiEstimation.publicId ?? "-1") ?? -1,
                  routeNumber: apiEstimation.routeNumber ?? "-",
                  destination: apiEstimation.destination ?? "-",
                  eta: apiEstimation.time ?? "",
                  busNumber: Int(apiEstimation.busNumber ?? "-1")
               )
            )
         }
         
         Appstate.shared.change(to: .idle, for: .estimations)
         
         return tempFormattedEstimations
         
      } catch {
         Appstate.shared.change(to: .error, for: .estimations)
         print("ERROR IN ESTIMATIONS: \(error)")
         return []
      }
      
   }
   
   
   
}
