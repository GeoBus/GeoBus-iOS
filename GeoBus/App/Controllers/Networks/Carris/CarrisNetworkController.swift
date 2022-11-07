import Foundation
import Combine


/* * */
/* MARK: - CARRIS NETWORK CONTROLLER */
/* This class controls all things Carris Network related. Keeping logic centralized */
/* allows for code reuse, less plumbing passing objects from one class to another and less */
/* clutter overall. If the data is provided by Carris, it should be controlled by this class. */


@MainActor
class CarrisNetworkController: ObservableObject {
   
   /* * */
   /* MARK: - 1. SETTINGS */
   /* In this section one can find private constants for update intervals, */
   /* storage keys and more. Change these values with caution because they can */
   /* trigger updates on the users devices, which can take a long time or fail. */
   
   private let carrisNetworkUpdateInterval: Int = 86400 * 5 // 5 days
   
   private let secondsToConsiderVehicleAsStale: Int = 300 // 3 minutes
   
   private let storageKeyForLastUpdatedCarrisNetwork: String = "carris_lastUpdatedNetwork"
   private let storageKeyForSavedStops: String = "carris_savedStops"
   private let storageKeyForFavoriteStops: String = "carris_favoriteStops"
   private let storageKeyForSavedRoutes: String = "carris_savedRoutes"
   private let storageKeyForFavoriteRoutes: String = "carris_favoriteRoutes"
   private let storageKeyForCommunityDataProviderStatus: String = "carris_communityDataProviderStatus"
   
   
   
   /* * */
   /* MARK: - 2. PUBLISHED VARIABLES */
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
   @Published var activeVehicle: CarrisNetworkModel.Vehicle? = nil
   
   @Published var favorites_routes: [CarrisNetworkModel.Route] = []
   @Published var favorites_stops: [CarrisNetworkModel.Stop] = []
   
   @Published var communityDataProviderStatus: Bool = false
   
   
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - 3. INITIALIZER */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* * */
   /* MARK: - 3.1. SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   public static let shared = CarrisNetworkController()
   
   
   
   /* * */
   /* MARK: - 3.2. INITIALIZE CLASS */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. After this, check if */
   /* this stored data needs an update or not. */
   
   private init() {
      
      // Unwrap last timestamp from Storage
      if let unwrappedLastUpdatedNetwork = UserDefaults.standard.string(forKey: storageKeyForLastUpdatedCarrisNetwork) {
         self.lastUpdatedNetwork = unwrappedLastUpdatedNetwork
      }
      
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
      
      // Unwrap Community Provider Status from Storage
      self.communityDataProviderStatus = UserDefaults.standard.bool(forKey: storageKeyForCommunityDataProviderStatus)
      
      // Check if network needs an update
      self.update(reset: false)
      
   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - 4. UPDATE DATA */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* * */
   /* MARK: - 4.1. UPDATE NETWORK MODEL */
   /* This function decides whether to update the complete network model */
   /* if it is considered outdated or is inexistent on device storage. */
   /* Provide a convenience method to allow user-requested updates from the UI. */
   
   public func resetAndUpdateNetwork() {
      self.update(reset: true)
   }
   
   private func update(reset forceUpdate: Bool) {
      Task {
         
         // Conditions to update
         let lastUpdateIsLongerThanInterval = Helpers.getSecondsFromISO8601DateString(self.lastUpdatedNetwork ?? "") > self.carrisNetworkUpdateInterval
         let savedNetworkDataIsEmpty = allRoutes.isEmpty || allStops.isEmpty
         let updateIsForcedByCaller = forceUpdate
         
         // Proceed if at least one condition is true
         if (lastUpdateIsLongerThanInterval || savedNetworkDataIsEmpty || updateIsForcedByCaller) {
            
            // Delete everything from storage
            UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
               UserDefaults.standard.removeObject(forKey: key)
            }
            
            // Restore deleted stored values
            UserDefaults.standard.set(communityDataProviderStatus, forKey: storageKeyForCommunityDataProviderStatus)
            
            // Fetch the updated network from the API
            await fetchStopsFromCarrisAPI()
            await fetchRoutesFromCarrisAPI()
            
            // Replace timestamp in storage with current time
            let timestampOfCurrentUpdate = ISO8601DateFormatter().string(from: Date.now)
            UserDefaults.standard.set(timestampOfCurrentUpdate, forKey: storageKeyForLastUpdatedCarrisNetwork)
            
         }
         
         // Get favorites from KVS
         self.retrieveFavoritesFromKVS()
         
         // Always update vehicles and favorites
         self.refresh()
         
      }
   }
   
   
   
   /* * */
   /* MARK: - 4.2. REFRESH DATA */
   /* This function initiates vehicles refresh from Carris API, updates the ‹activeVehicles› array */
   /* and syncronizes favorites with iCloud, to ensure changes are always up to date. */
   
   public func refresh() {
      Task {
         // Update all vehicles from Carris API
         await self.fetchVehiclesListFromCarrisAPI()
         
         // DEBUG !
//         if (self.activeVehicle == nil) {
//            self.select(vehicle: self.allVehicles[1].id)
//            Appstate.shared.present(sheet: .carris_vehicleDetails)
//         }
         // ! DEBUG
         
         // DEBUG !
//         if (self.activeRoute == nil) {
//            _ = self.select(route: "758")
//            // Appstate.shared.present(sheet: .carris_vehicleDetails)
//         }
         // ! DEBUG
         
         // If there is an active vehicle, also refresh it's details
         if (self.activeVehicle != nil) {
            await self.fetchVehicleDetailsFromCarrisAPI(for: self.activeVehicle!.id)
            // If Community provider is also enabled, then also refresh those details
            if (self.communityDataProviderStatus) {
               await self.fetchVehicleDetailsFromCommunityAPI(for: self.activeVehicle!.id)
            }
         }
         // Update the list of active vehicles (the current selected route)
         self.populateActiveVehicles()
      }
   }
   
   
   
   /* * */
   /* MARK: - 4.3. COMMUNITY PROVIDER */
   /* Call this function to switch Community Data ON or OFF. */
   /* This switches in memory for the current session, and stores the new setting in storage. */
   
   public func toggleCommunityDataProviderStatus(to newStatus: Bool) {
      self.communityDataProviderStatus = newStatus
      UserDefaults.standard.set(newStatus, forKey: storageKeyForCommunityDataProviderStatus)
      print("GeoBus: Carris API: ‹toggleCommunityDataProviderTo()› Community Data switched \(newStatus ? "ON" : "OFF")")
      self.refresh()
   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - 5. FORMAT NETWORK */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* * */
   /* MARK: - 5.1. STOPS: FETCH & FORMAT FROM CARRIS API */
   /* Call Carris API and retrieve all stops. Format them to the app model. */
   
   private func fetchStopsFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Stops_Sync_START)
      Appstate.shared.change(to: .loading, for: .stops)
      
      print("GeoBus: Carris API: Stops: Starting update...")
      
      do {
         
         // Request API Stops List
         let rawDataCarrisAPIStopsList = try await CarrisAPI.shared.request(for: "busstops")
         
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
                     id: Int(availableStop.publicId ?? "-1") ?? -1,
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
         
         print("GeoBus: Carris API: Stops: Update complete!")
         
         Analytics.shared.capture(event: .Stops_Sync_OK)
         Appstate.shared.change(to: .idle, for: .stops)
         
      } catch {
         Analytics.shared.capture(event: .Stops_Sync_ERROR)
         Appstate.shared.change(to: .error, for: .stops)
         print("GeoBus: Carris API: Stops: Error found while updating. More info: \(error)")
      }
      
   }
   
   
   
   /* * */
   /* MARK: - 5.2. ROUTES: FETCH & FORMAT FROM CARRIS API */
   /* This function first fetches the Routes List from Carris API, */
   /* which is an object that contains all the available routes. */
   /* The information for each Route is very short, so it is necessary to retrieve */
   /* the details for each route. Here, we only care about the publicy available routes. */
   /* After, for each route, its details are formatted and transformed into a Route. */
   
   private func fetchRoutesFromCarrisAPI() async {
      
      Analytics.shared.capture(event: .Routes_Sync_START)
      Appstate.shared.change(to: .loading, for: .routes)
      
      print("GeoBus: Carris API: Routes: Starting update...")
      
      do {
         
         // Request API Routes List
         let rawDataCarrisAPIRoutesList = try await CarrisAPI.shared.request(for: "Routes")
         let decodedCarrisAPIRoutesList = try JSONDecoder().decode([CarrisAPIModel.RoutesList].self, from: rawDataCarrisAPIRoutesList)
         
         self.networkUpdateProgress = decodedCarrisAPIRoutesList.count
         
         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllRoutes: [CarrisNetworkModel.Route] = []
         
         // For each available route in the API,
         for availableRoute in decodedCarrisAPIRoutesList {
            
            if (availableRoute.isPublicVisible ?? false) {
               
               print("GeoBus: Carris API: Routes: Downloading route \(String(describing: availableRoute.routeNumber))...")
               
               // Request Route Detail for ‹routeNumber›
               let rawDataCarrisAPIRouteDetail = try await CarrisAPI.shared.request(for: "Routes/\(availableRoute.routeNumber ?? "-")")
               let decodedAPIRouteDetail = try JSONDecoder().decode(CarrisAPIModel.Route.self, from: rawDataCarrisAPIRouteDetail)
               
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
               
               print("GeoBus: Carris API: Routes: Route \(String(describing: availableRoute.routeNumber)) complete!")
               
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
         
         print("GeoBus: Carris API: Routes: Update complete!")
         
         Analytics.shared.capture(event: .Routes_Sync_OK)
         Appstate.shared.change(to: .idle, for: .routes)
         
      } catch {
         Analytics.shared.capture(event: .Routes_Sync_ERROR)
         Appstate.shared.change(to: .error, for: .routes)
         print("GeoBus: Carris API: Routes: Error found while updating. More info: \(error)")
      }
      
   }
   
   
   
   /* * */
   /* MARK: - 5.3. VARIANTS: FORMAT CARRIS ROUTE VARIANTS */
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
   /* MARK: - 5.4. CONNECTIONS: FORMAT CARRIS CONNECTIONS */
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
   /* MARK: - 6. FAVORITES */
   /* This section holds the logic to deal with favorites from iCloud Key-Value-Storage. */
   
   
   /* * */
   /* MARK: - 6.1. RETRIEVE FAVORITES FROM ICLOUD KVS */
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
   /* MARK: - 6.2. SAVE FAVORITES TO ICLOUD KVS */
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
   /* MARK: - 6.3. TOGGLE ROUTES AND STOPS AS FAVORITES */
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
   /* MARK: - 6.4: IS FAVORITE CHECKER */
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
   /* MARK: - 7. FINDERS */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* * */
   /* MARK: - 7.1. FIND OBJECTS BY IDENTIFIER */
   /* These functions search for the provided object identifier in the storage arrays */
   /* and return it if found or nil if not found. */
   
   private func find(vehicle vehicleId: Int) -> CarrisNetworkModel.Vehicle? {
      if let requestedVehicleObject = self.allVehicles[withId: vehicleId] {
         return requestedVehicleObject
      } else {
         return nil
      }
   }
   
   private func find(route routeNumber: String) -> CarrisNetworkModel.Route? {
      if let requestedRouteObject = self.allRoutes[withId: routeNumber] {
         return requestedRouteObject
      } else {
         return nil
      }
   }
   
   public func find(stop stopId: Int) -> CarrisNetworkModel.Stop? {
      if let requestedStopObject = self.allStops[withId: stopId] {
         return requestedStopObject
      } else {
         return nil
      }
   }
   
   private func find(route routeNumber: String, variant: Int, direction: String) -> CarrisNetworkModel.Stop? {
      guard let requestedRouteObject = self.find(route: routeNumber) else {
         return nil
      }
      
      if (variant >= requestedRouteObject.variants.count) {
         return nil
      }
      
      let requestedVariantObject = requestedRouteObject.variants[variant]
      
      switch direction {
         case "ASC":
            return requestedVariantObject.ascendingItinerary?.last?.stop
         case "DESC":
            return requestedVariantObject.descendingItinerary?.last?.stop
         case "CIRC":
            return requestedVariantObject.circularItinerary?.last?.stop
         default:
            return nil
      }
      
   }
   
   
   public func getDirectionFrom(string directionString: String?) -> CarrisNetworkModel.Direction? {
      switch directionString {
         case "ASC":
            return .ascending
         case "DESC":
            return .descending
         case "CIRC":
            return .circular
         default:
            return nil
      }
   }
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - 8. SELECTORS */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* * */
   /* MARK: - 8.1: OBJECT SELECTORS */
   /* These functions select and deselect the currently active objects. */
   /* Provide public functions to more easily select object by their identifier. */
   
   
   enum SelectableObject {
      case route
      case variant
      case connection
      case vehicle
      case stop
      case all
   }
   
   
   public func deselect(_ objectType: [SelectableObject]) {
      for type in objectType {
         switch type {
            case .route:
               self.activeRoute = nil
            case .variant:
               self.activeVariant = nil
            case .connection:
               self.activeConnection = nil
            case .vehicle:
               self.activeVehicle = nil
            case .stop:
               self.activeStop = nil
            case .all:
               self.deselect([.route, .variant, .connection, .vehicle, .stop])
         }
      }
   }
   
   
   private func select(route: CarrisNetworkModel.Route) {
      self.deselect([.all])
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
   
   
   public func deselect(connection: CarrisNetworkModel.Connection) {
      self.activeConnection = connection
   }
   
   public func select(connection: CarrisNetworkModel.Connection) {
      self.activeConnection = connection
   }
   
   public func select(stop: CarrisNetworkModel.Stop) {
      self.deselect([.all])
      self.activeStop = stop
   }
   
   public func select(stop stopId: Int) -> Bool {
      let stop = self.find(stop: stopId)
      if (stop != nil) {
         self.deselect([.all])
         self.activeStop = stop
//         self.select(stop: stop!)
         return true
      } else {
         return false
      }
   }
   
   
   public func select(vehicle vehicleId: Int?) {
      if (vehicleId != nil) {
         if let foundVehicle = self.find(vehicle: vehicleId!) {
            Task {
               await self.fetchVehicleDetailsFromCarrisAPI(for: foundVehicle.id)
               if (self.communityDataProviderStatus) {
                  await self.fetchVehicleDetailsFromCommunityAPI(for: foundVehicle.id)
               }
               self.activeVehicle = foundVehicle
            }
         }
      }
   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - 9. VEHICLES */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* * */
   /* MARK: - 9.1. VEHICLES: SET ACTIVE VEHICLES */
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
   /* MARK: - 9.2. FETCH ALL VEHICLES FROM CARRIS API */
   /* This function calls the Carris API and receives vehicle metadata, */
   /* including positions, for all currently active vehicles, */
   /* and stores them in the ‹allVehicles› array. */
   
   func fetchVehiclesListFromCarrisAPI() async {
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      print("GeoBus: Carris API: Vehicles List: Starting update...")
      
      do {
         // Request all Vehicles from API
         let rawDataCarrisAPIVehiclesList = try await CarrisAPI.shared.request(for: "vehicleStatuses")
         
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
                  allVehicles[indexOfVehicleInArray!].direction = getDirectionFrom(string: vehicleSummary.direction)
                  
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
         
         print("GeoBus: Carris API: Vehicles List: Update complete!")
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("GeoBus: Carris API: Vehicles List: Error found while updating. More info: \(error)")
         return
      }
      
   }
   
   
   
   /* * */
   /* MARK: - 9.3. FETCH VEHICLE DETAILS FROM CARRIS API */
   /* This function calls the Carris API SGO endpoint to retrieve additional vehicle metadata, */
   /* such as location, license plate number and last stop on the current trip. Provide a convenience */
   /* function to allow the UI to request this information only when necessary. After retrieving the new details */
   /* fromt the API, re-populate the activeVehicles array to trigger an update in the UI. */
   
   private func fetchVehicleDetailsFromCarrisAPI(for vehicleId: Int) async {
      
      Appstate.shared.change(to: .loading, for: .carris_vehicleDetails)
      
      print("GeoBus: Carris API: Vehicle Details: Starting update...")
      
      do {
         
         // Request Vehicle Detail (SGO)
         let rawDataCarrisAPIVehicleDetail = try await CarrisAPI.shared.request(for: "SGO/busNumber/\(vehicleId)")
         
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
            allVehicles[indexOfVehicleInArray!].hasLoadedCarrisDetails = true
         }
         
         print("GeoBus: Carris API: Vehicle Details: Update complete!")
         
         Appstate.shared.change(to: .idle, for: .carris_vehicleDetails)
         
      } catch {
         Appstate.shared.change(to: .error, for: .carris_vehicleDetails)
         print("GeoBus: Carris API: Vehicles Details: Error found while updating. More info: \(error)")
         return
      }
      
   }
   
   
   
   /* * */
   /* MARK: - 9.4. FETCH VEHICLE DETAILS FROM COMMUNITY API */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   private func fetchVehicleDetailsFromCommunityAPI(for vehicleId: Int) async {
      
      Appstate.shared.change(to: .loading, for: .carris_vehicleDetails)
      
      print("GeoBus: Community API: Vehicle Details: Starting update...")
      
      do {
         
         // Request Vehicle Detail (SGO)
         let rawDataCarrisCommunityAPIVehicleDetail = try await CarrisCommunityAPI.shared.request(for: "estbus?busNumber=\(vehicleId)")
         
         let decodedCarrisCommunityAPIVehicleDetail = try JSONDecoder().decode([CarrisCommunityAPIModel.Vehicle].self, from: rawDataCarrisCommunityAPIVehicleDetail)
         
         
         if (decodedCarrisCommunityAPIVehicleDetail[0].estimatedRouteResults != nil) {
            
            var tempRouteOverview: [CarrisNetworkModel.Estimation] = []
            
            for routeResult in decodedCarrisCommunityAPIVehicleDetail[0].estimatedRouteResults! {
               tempRouteOverview.append(
                  CarrisNetworkModel.Estimation(
                     stopId: Int(routeResult.estimatedRouteStopId ?? "-1") ?? -1,
                     routeNumber: "",
                     destination: "",
                     eta: routeResult.estimatedTimeofArrivalCorrected,
                     hasArrived: routeResult.estimatedPreviouslyArrived
                  )
               )
            }
            
            
            let indexOfVehicleInArray = allVehicles.firstIndex(where: {
               $0.id == vehicleId
            })
            
            if (indexOfVehicleInArray != nil) {
               allVehicles[indexOfVehicleInArray!].routeOverview = tempRouteOverview
               allVehicles[indexOfVehicleInArray!].hasLoadedCommunityDetails = true
            }
            
         }
         
         print("GeoBus: Community API: Vehicle Details: Update complete!")
         
         Appstate.shared.change(to: .idle, for: .carris_vehicleDetails)
         
      } catch {
         Appstate.shared.change(to: .error, for: .carris_vehicleDetails)
         print("GeoBus: Community API: Vehicles Details: Error found while updating. More info: \(error)")
         return
      }
      
   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - 10. ESTIMATES */
   /* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi ut ornare ipsum. */
   /* Nunc neque nulla, pretium ac lectus id, scelerisque facilisis est. */
   
   
   /* MARK: - 10.1. GET ESTIMATION */
   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.
   
   public func getEstimation(for stopId: Int) async -> [CarrisNetworkModel.Estimation] {
      if (!communityDataProviderStatus) {
         return await self.fetchEstimationsFromCarrisAPI(for: stopId)
      } else {
         return await self.fetchEstimationsFromCommunityAPI(for: stopId)
      }
   }
   
   
   
   /* MARK: - 10.2. GET CARRIS ESTIMATIONS */
   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.
   
   public func fetchEstimationsFromCarrisAPI(for stopId: Int) async -> [CarrisNetworkModel.Estimation] {
      
      Appstate.shared.change(to: .loading, for: .estimations)
      
      print("GeoBus: Carris API: Estimations: Starting update...")
      
      do {
         // Request API Estimations List
         let rawDataCarrisAPIEstimations = try await CarrisAPI.shared.request(for: "Estimations/busStop/\(stopId)/top/5")
         let decodedCarrisAPIEstimations = try JSONDecoder().decode([CarrisAPIModel.Estimation].self, from: rawDataCarrisAPIEstimations)
         
         var tempFormattedEstimations: [CarrisNetworkModel.Estimation] = []
         
         
         // For each available vehicles in the API
         for apiEstimation in decodedCarrisAPIEstimations {
            tempFormattedEstimations.append(
               CarrisNetworkModel.Estimation(
                  stopId: Int(apiEstimation.publicId ?? "-1") ?? -1,
                  routeNumber: apiEstimation.routeNumber,
                  destination: apiEstimation.destination,
                  eta: apiEstimation.time ?? "",
                  busNumber: Int(apiEstimation.busNumber ?? "")
               )
            )
         }
         
         print("GeoBus: Carris API: Estimations: Update complete!")
         
         Appstate.shared.change(to: .idle, for: .estimations)
         
         return tempFormattedEstimations
         
      } catch {
         Appstate.shared.change(to: .error, for: .estimations)
         print("GeoBus: Carris API: Estimations: Error found while updating. More info: \(error)")
         return []
      }
      
   }
   
   
   
   /* MARK: - 10.3. GET COMMUNITY ESTIMATIONS */
   // This function calls the API to retrieve estimations for the provided stop 'publicId'.
   // It formats and returns the results to the caller.
   
   public func fetchEstimationsFromCommunityAPI(for stopId: Int) async -> [CarrisNetworkModel.Estimation] {
      
      Appstate.shared.change(to: .loading, for: .estimations)
      
      print("GeoBus: Carris API: Estimations: Starting update...")
      
      do {
         // Request API Estimations List
         let rawDataCarrisCommunityAPIEstimations = try await CarrisCommunityAPI.shared.request(for: "eststop?busStop=\(stopId)")
         let decodedCarrisCommunityAPIEstimations = try JSONDecoder().decode([CarrisCommunityAPIModel.Estimation].self, from: rawDataCarrisCommunityAPIEstimations)
         
         
         var tempFormattedEstimations: [CarrisNetworkModel.Estimation] = []
         
         
         // For each available vehicles in the API
         for apiEstimation in decodedCarrisCommunityAPIEstimations {
            
            let destinationStop = find(
               route: apiEstimation.routeNumber ?? "-",
               variant: apiEstimation.variantNumber ?? -1,
               direction: apiEstimation.direction ?? "-"
            )
            
            tempFormattedEstimations.append(
               CarrisNetworkModel.Estimation(
                  stopId: stopId,
                  routeNumber: apiEstimation.routeNumber ?? "-",
                  destination: destinationStop?.name ?? "-",
                  eta: apiEstimation.estimatedTimeofArrivalCorrected ?? "",
                  busNumber: apiEstimation.busNumber ?? -1
               )
            )
         }
         
         print("GeoBus: Carris API: Estimations: Update complete!")
         
         Appstate.shared.change(to: .idle, for: .estimations)
         
         return tempFormattedEstimations
         
      } catch {
         Appstate.shared.change(to: .error, for: .estimations)
         print("GeoBus: Carris API: Estimations: Error found while updating. More info: \(error)")
         return []
      }
      
   }
   
   
}
