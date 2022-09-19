//
//  RoutesController.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 08/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import Combine

@MainActor
class RoutesController: ObservableObject {

   /* MARK: - Variables */

   private let storageKeyForAllRoutes: String = "routes_allRoutes"
   @Published var allRoutes: [Route] = []

   private let storageKeyForLastUpdatedRoutes: String = "routes_lastUpdatedRoutes"
   private var lastUpdatedRoutes: String? = nil

   private let storageKeyForFavoriteRoutes: String = "routes_favoriteRoutes"
   @Published var favorites: [Route] = []

   @Published var selectedRoute: Route?
   @Published var selectedVariant: Variant?

   @Published var totalRoutesLeftToUpdate: Int? = nil



   /* MARK: - INITIALIZER */

   // Retrieve data from UserDefaults on init.

   init() {
      // Unwrap and Decode all stops
      if let unwrappedAllRoutes = UserDefaults.standard.data(forKey: storageKeyForAllRoutes) {
         if let decodedAllRoutes = try? JSONDecoder().decode([Route].self, from: unwrappedAllRoutes) {
            self.allRoutes = decodedAllRoutes
         }
      }
      // Unwrap lastUpdatedStops timestamp
      if let unwrappedLastUpdatedRoutes = UserDefaults.standard.string(forKey: storageKeyForLastUpdatedRoutes) {
         self.lastUpdatedRoutes = unwrappedLastUpdatedRoutes
      }
   }



   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */

   var appstate = Appstate()
   var authentication = Authentication()

   func receive(state: Appstate, auth: Authentication) {
      self.appstate = state
      self.authentication = auth
   }



   /* MARK: - Selectors */
   
   // Getters and Setters for published and private variables.

   private func select(route: Route) {
      self.selectedRoute = route
      self.select(variant: route.variants[0])
   }

   func select(route routeNumber: String) {
      let route = self.findRoute(by: routeNumber)
      if (route != nil) {
         self.select(route: route!)
      }
   }

   func select(route routeNumber: String, returnResult: Bool) -> Bool {
      let route = self.findRoute(by: routeNumber)
      if (route != nil) {
         self.select(route: route!)
         return true
      } else {
         return false
      }
   }


   func select(variant: Variant) {
      self.selectedVariant = variant
   }


   func deselect() {
      self.selectedRoute = nil
      self.selectedVariant = nil
   }



   /* MARK: - Check for Updates from Carris API */

   // This function decides whether to update available routes
   // if they are outdated. For now, do this once a day.

   func update(forced: Bool = false) {

      let formatter = ISO8601DateFormatter()

      if (lastUpdatedRoutes == nil || allRoutes.isEmpty || forced) {
         Task {
            await fetchRoutesFromAPI()
            let timestamp = formatter.string(from: Date.now)
            UserDefaults.standard.set(timestamp, forKey: storageKeyForLastUpdatedRoutes)
         }
      } else {
         // Calculate time interval
         let formattedDateObj = formatter.date(from: lastUpdatedRoutes!)
         let secondsPassed = Int(formattedDateObj?.timeIntervalSinceNow ?? -1)

         if ( (secondsPassed * -1) > (86400 * 5) ) { // 86400 seconds * 5 = 5 days
            Task {
               await fetchRoutesFromAPI()
               let timestamp = formatter.string(from: Date.now)
               UserDefaults.standard.set(timestamp, forKey: storageKeyForLastUpdatedRoutes)
            }
         }
      }

      // Retrieve favorites at app launch
      self.retrieveFavorites()

   }



   /* MARK: - Retrieve Favourite Routes from iCloud KVS */

   // This function retrieves favorites from iCloud Key-Value-Storage.

   func retrieveFavorites() {

      // Get from iCloud
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.synchronize()

      let savedFavorites = iCloudKeyStore.array(forKey: storageKeyForFavoriteRoutes) as? [String] ?? []

      // Save to array
      for routeNumber in savedFavorites {
         let route = findRoute(by: routeNumber)
         if (route != nil) {
            favorites.append(route!)
         }
      }

   }



   /* MARK: - Save Favorite Routes to iCloud KVS */

   // This function saves a representation of the routes stored in the favorites array
   // to iCloud Key-Value-Store. This function should be called whenever a change
   // in favorites occurs, to ensure consistency across devices.

   func saveFavorites() {
      var favoritesToSave: [String] = []
      for favRoute in favorites {
         favoritesToSave.append(favRoute.number)
      }
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.set(favoritesToSave, forKey: storageKeyForFavoriteRoutes)
      iCloudKeyStore.synchronize()
   }



   /* MARK: - Toggle Route as Favorite */

   // This function marks a route as favorite if it is not,
   // and removes it from favorites if it is.

   func toggleFavorite(route: Route) {

      if let index = self.favorites.firstIndex(of: route) {
         self.favorites.remove(at: index)
         self.appstate.capture(event: "Routes-Details-RemoveFromFavorites", properties: ["routeNumber": route.number])
      } else {
         self.favorites.append(route)
         self.appstate.capture(event: "Routes-Details-AddToFavorites", properties: ["routeNumber": route.number])
      }

      saveFavorites()

   }



   /* MARK: - Reorder Favorites */

   // This function marks a route as favorite if it is not,

   func reorderFavorites(fromOffsets: IndexSet, toOffset: Int) {

      self.favorites.move(fromOffsets: fromOffsets, toOffset: toOffset)

      saveFavorites()

   }



   /* MARK: - Is Favourite */

   // This function checks if a route is marked as favorite.

   func isFavourite(route: Route) -> Bool {
      return favorites.contains(route)
   }



   /* MARK: - Fetch & Format Routes From Carris API */

   // This function first fetches the Routes List,
   // which is an object that contains all the available routes from the API.
   // The information for each Route is very short, so it is necessary to retrieve
   // the details for each route. Here, we only care about the publicy available routes.
   // After, for each route, it's details are formatted and transformed into a Route.

   func fetchRoutesFromAPI() async {

      appstate.change(to: .loading, for: .routes)

      print("Fetching Routes: Starting...")

      do {
         // Request API Routes List
         var requestAPIRoutesList = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/Routes")!)
         requestAPIRoutesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIRoutesList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIRoutesList.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIRoutesList, rawResponseAPIRoutesList) = try await URLSession.shared.data(for: requestAPIRoutesList)
         let responseAPIRoutesList = rawResponseAPIRoutesList as? HTTPURLResponse

         // Check status of response
         if (responseAPIRoutesList?.statusCode == 401) {
            await self.authentication.authenticate()
            await self.fetchRoutesFromAPI()
            return
         } else if (responseAPIRoutesList?.statusCode != 200) {
            print(responseAPIRoutesList as Any)
            throw Appstate.CarrisAPIError.unavailable
         }

         let decodedAPIRoutesList = try JSONDecoder().decode([APIRoutesList].self, from: rawDataAPIRoutesList)


         self.totalRoutesLeftToUpdate = decodedAPIRoutesList.count


         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllRoutes: [Route] = []

         // For each available route in the API,
         for availableRoute in decodedAPIRoutesList {

            if (availableRoute.isPublicVisible ?? false) {

               print("Route: Route.\(String(describing: availableRoute.routeNumber)) starting...")

               // Request Route Detail for .routeNumber
               var requestAPIRouteDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/Routes/\(availableRoute.routeNumber ?? "invalid-route-number")")!)
               requestAPIRouteDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
               requestAPIRouteDetail.addValue("application/json", forHTTPHeaderField: "Accept")
               requestAPIRouteDetail.setValue("Bearer \(authentication.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
               let (rawDataAPIRouteDetail, rawResponseAPIRouteDetail) = try await URLSession.shared.data(for: requestAPIRouteDetail)
               let responseAPIRouteDetail = rawResponseAPIRouteDetail as? HTTPURLResponse

               // Check status of response
               if (responseAPIRouteDetail?.statusCode == 401) {
                  Task {
                     await self.authentication.authenticate()
                     await self.fetchRoutesFromAPI()
                  }
                  return
               } else if (responseAPIRouteDetail?.statusCode != 200) {
                  print(responseAPIRouteDetail as Any)
                  throw Appstate.CarrisAPIError.unavailable
               }


               let decodedAPIRouteDetail = try JSONDecoder().decode(APIRoute.self, from: rawDataAPIRouteDetail)

               // Define a temporary variable to store formatted route variants
               var formattedRouteVariants: [Variant] = []

               // For each variant in route,
               // check if it is currently active, format it
               // and append the result to the temporary variable.
               for apiRouteVariant in decodedAPIRouteDetail.variants ?? [] {
                  if (apiRouteVariant.isActive ?? false) {
                     formattedRouteVariants.append(
                        formatRawRouteVariant(
                           rawVariant: apiRouteVariant,
                           isCircular: decodedAPIRouteDetail.isCirc ?? false
                        )
                     )
                  }
               }

               // Build the formatted route object
               let formattedRoute = Route(
                  number: decodedAPIRouteDetail.routeNumber ?? "-",
                  name: decodedAPIRouteDetail.name ?? "-",
                  kind: Globals().getKind(by: decodedAPIRouteDetail.routeNumber ?? "-"),
                  variants: formattedRouteVariants
               )

               // Save the formatted route object in the allRoutes temporary variable
               tempAllRoutes.append(formattedRoute)

               self.totalRoutesLeftToUpdate! -= 1

               print("Route: Route.\(String(describing: formattedRoute.number)) complete.")

               try await Task.sleep(nanoseconds: 100_000_000)

            }

         }

         // Finally, save the temporary variables into storage,
         // while removing the previous, old ones.
         self.allRoutes.removeAll()
         self.allRoutes.append(contentsOf: tempAllRoutes)
         if let encodedAllRoutes = try? JSONEncoder().encode(self.allRoutes) {
            UserDefaults.standard.set(encodedAllRoutes, forKey: storageKeyForAllRoutes)
         }

         print("Fetching Routes: Complete!")

         appstate.capture(event: "Routes-Sync-OK")
         appstate.change(to: .idle, for: .routes)

      } catch {
         appstate.capture(event: "Routes-Sync-ERROR")
         appstate.change(to: .error, for: .routes)
         print("Fetching Routes: Error!")
         print(error)
         print("************")
      }

   }



   /* MARK: - Format Route Variants */

   // Parse and simplify the data model for variants

   func formatRawRouteVariant(rawVariant: APIRouteVariant, isCircular: Bool) -> Variant {

      // Create a temporary variable to store the final RouteVariant
      var formattedVariant = Variant(
         number: rawVariant.variantNumber ?? -1,
         isCircular: isCircular,
         upItinerary: nil,
         downItinerary: nil,
         circItinerary: nil
      )

      // For each Itinerary type,
      // check if it is defined (not nil) in the raw object

      // For UpItinerary:
      if (rawVariant.upItinerary != nil) {

         // Change the temporary variable property to an empty array
         formattedVariant.upItinerary = []

         // For each connection,
         // convert the nested objects into a simplified RouteStop object
         for rawConnection in rawVariant.upItinerary!.connections ?? [] {

            // Append new values to the temporary variable property directly
            formattedVariant.upItinerary!.append(
               Stop(
                  publicId: rawConnection.busStop?.publicId ?? "-",
                  name: rawConnection.busStop?.name ?? "-",
                  lat: rawConnection.busStop?.lat ?? 0,
                  lng: rawConnection.busStop?.lng ?? 0,
                  orderInRoute: rawConnection.orderNum,
                  direction: .ascending
               )
            )

         }

         // Sort the stops
         formattedVariant.upItinerary!.sort(by: { $0.orderInRoute! < $1.orderInRoute! })

      }

      // For DownItinerary:
      if (rawVariant.downItinerary != nil) {

         // Change the temporary variable property to an empty array
         formattedVariant.downItinerary = []

         // For each connection,
         // convert the nested objects into a simplified RouteStop object
         for rawConnection in rawVariant.downItinerary!.connections ?? [] {

            // Append new values to the temporary variable property directly
            formattedVariant.downItinerary!.append(
               Stop(
                  publicId: rawConnection.busStop?.publicId ?? "-",
                  name: rawConnection.busStop?.name ?? "-",
                  lat: rawConnection.busStop?.lat ?? 0,
                  lng: rawConnection.busStop?.lng ?? 0,
                  orderInRoute: rawConnection.orderNum,
                  direction: .descending
               )
            )

         }

         // Sort the stops
         formattedVariant.downItinerary!.sort(by: { $0.orderInRoute! < $1.orderInRoute! })

      }

      // For CircItinerary:
      if (rawVariant.circItinerary != nil) {

         // Change the temporary variable property to an empty array
         formattedVariant.circItinerary = []

         // For each connection,
         // convert the nested objects into a simplified RouteStop object
         for rawConnection in rawVariant.circItinerary!.connections ?? [] {

            // Append new values to the temporary variable property directly
            formattedVariant.circItinerary!.append(
               Stop(
                  publicId: rawConnection.busStop?.publicId ?? "-",
                  name: rawConnection.busStop?.name ?? "-",
                  lat: rawConnection.busStop?.lat ?? 0,
                  lng: rawConnection.busStop?.lng ?? 0,
                  orderInRoute: rawConnection.orderNum,
                  direction: .circular
               )
            )

         }

         // Sort the stops
         formattedVariant.circItinerary!.sort(by: { $0.orderInRoute! < $1.orderInRoute! })

      }

      if (formattedVariant.isCircular) {
         formattedVariant.name = getTerminalStopNameForVariant(variant: formattedVariant, direction: .circular)
      } else {
         let firstStop = getTerminalStopNameForVariant(variant: formattedVariant, direction: .ascending)
         let lastStop = getTerminalStopNameForVariant(variant: formattedVariant, direction: .descending)
         formattedVariant.name = "\(firstStop) ⇄ \(lastStop)"
      }

      // Finally, return the temporary variable to the caller
      return formattedVariant

   }



   /* MARK: - Find Route by RouteNumber */

   // This function searches for the provided routeNumber in all routes array,
   // and returns it if found. If not found, returns nil.

   func findRoute(by routeNumber: String) -> Route? {

      // Find index of route matching requested routeNumber
      let indexOfRouteInArray = allRoutes.firstIndex(where: { (route) -> Bool in
         route.number == routeNumber // test if this is the item we're looking for
      }) ?? nil // If the item does not exist, return default value nil

      // If a match is found...
      if (indexOfRouteInArray != nil) {
         return allRoutes[indexOfRouteInArray!]
      } else {
         return nil
      }

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



}
