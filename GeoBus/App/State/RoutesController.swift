//
//  RoutesController.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 08/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import Boutique
import Combine

@MainActor
class RoutesController: ObservableObject {

   /* MARK: - Variables */

   @Stored(in: .routesStore) var allRoutes

   @Published var state: Appstate.State = .idle

   @Published var favorites: [Route] = []

   @Published var selectedRoute: Route?
   @Published var selectedVariant: Variant?

   @StoredValue(key: "lastUpdatedRoutes") var lastUpdateRoutes: String? = nil



   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */

   var appstate = Appstate()
   var authentication = Authentication()

   func receive(state: Appstate, auth: Authentication) {
      self.appstate = state
      self.authentication = auth
   }



   /* MARK: - Selectors */
   
   // Getters and Setters for published and private variables.

   private func set(state: Appstate.State) {
      self.state = state
   }

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



   /* MARK: - Check for Updates from Carris API */

   // This function decides whether to update available routes
   // if they are outdated. For now, do this once a day.

   func update() async {

      let formatter = ISO8601DateFormatter()

      if (lastUpdateRoutes != nil || allRoutes.count > 0) {

         // Calculate time interval
         let formattedDateObj = formatter.date(from: lastUpdateRoutes!)
         let secondsPassed = Int(formattedDateObj?.timeIntervalSinceNow ?? -1)

         if ( (secondsPassed * -1) > (86400 * 5) ) { // 86400 seconds * 5 = 5 days
            await fetchRoutesFromAPI()
            let timestamp = formatter.string(from: Date.now)
            $lastUpdateRoutes.set(timestamp)
         }

      } else {
         appstate.change(to: .loading, for: .routes)
         await fetchRoutesFromAPI()
         let timestamp = formatter.string(from: Date.now)
         $lastUpdateRoutes.set(timestamp)
      }

      // Do the following in the main thread
      // because this is an async function.
      DispatchQueue.main.async {
         self.retrieveFavorites()
      }

   }



   /* MARK: - Retrieve Favourite Routes from iCloud KVS */

   // This function retrieves favorites from iCloud Key-Value-Storage.

   func retrieveFavorites() {

      // Get from iCloud
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.synchronize()

      let savedFavorites = iCloudKeyStore.array(forKey: "favoriteRoutes") as? [String] ?? []

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
      iCloudKeyStore.set(favoritesToSave, forKey: "favoriteRoutes")
      iCloudKeyStore.synchronize()
   }



   /* MARK: - Toggle Route as Favorite */

   // This function marks a route as favorite if it is not,
   // and removes it from favorites if it is.

   func toggleFavorite(route: Route) {

      if let index = self.favorites.firstIndex(of: route) {
         self.favorites.remove(at: index)
      } else {
         self.favorites.append(route)
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
            Task {
               await self.authentication.authenticate()
               await self.fetchRoutesFromAPI()
            }
            return
         } else if (responseAPIRoutesList?.statusCode != 200) {
            print(responseAPIRoutesList as Any)
            throw Appstate.CarrisAPIError.unavailable
         }

         let decodedAPIRoutesList = try JSONDecoder().decode([APIRoutesList].self, from: rawDataAPIRoutesList)

         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllRoutes: [Route] = []

         // For each available route in the API,
         for availableRoute in decodedAPIRoutesList {

            if (availableRoute.isPublicVisible) {

               // Request Route Detail for .routeNumber
               var requestAPIRouteDetail = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/Routes/\(availableRoute.routeNumber)")!)
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
               for apiRouteVariant in decodedAPIRouteDetail.variants {
                  if (apiRouteVariant.isActive) {
                     formattedRouteVariants.append(
                        formatRawRouteVariant(
                           rawVariant: apiRouteVariant,
                           isCircular: decodedAPIRouteDetail.isCirc
                        )
                     )
                  }
               }

               // Build the formatted route object
               let formattedRoute = Route(
                  number: decodedAPIRouteDetail.routeNumber,
                  name: decodedAPIRouteDetail.name,
                  kind: Globals().getKind(by: decodedAPIRouteDetail.routeNumber),
                  variants: formattedRouteVariants
               )

               // Save the formatted route object in the allRoutes temporary variable
               tempAllRoutes.append(formattedRoute)

            }

         }

         // Finally, save the temporary variables into storage,
         // while removing the previous, old ones.
         try await self.$allRoutes
            .removeAll()
            .add(tempAllRoutes)
            .run()

         print("Fetching Routes: Complete!")

         appstate.change(to: .idle, for: .routes)

      } catch {
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
         number: rawVariant.variantNumber,
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
         for rawConnection in rawVariant.upItinerary!.connections {

            // Append new values to the temporary variable property directly
            formattedVariant.upItinerary!.append(
               Stop(
                  orderInRoute: rawConnection.orderNum,
                  publicId: rawConnection.busStop.publicId,
                  name: rawConnection.busStop.name,
                  direction: .ascending,
                  lat: rawConnection.busStop.lat,
                  lng: rawConnection.busStop.lng
               )
            )

         }

         // Sort the stops
         formattedVariant.upItinerary!.sort(by: { $0.orderInRoute < $1.orderInRoute })

      }

      // For DownItinerary:
      if (rawVariant.downItinerary != nil) {

         // Change the temporary variable property to an empty array
         formattedVariant.downItinerary = []

         // For each connection,
         // convert the nested objects into a simplified RouteStop object
         for rawConnection in rawVariant.downItinerary!.connections {

            // Append new values to the temporary variable property directly
            formattedVariant.downItinerary!.append(
               Stop(
                  orderInRoute: rawConnection.orderNum,
                  publicId: rawConnection.busStop.publicId,
                  name: rawConnection.busStop.name,
                  direction: .descending,
                  lat: rawConnection.busStop.lat,
                  lng: rawConnection.busStop.lng
               )
            )

         }

         // Sort the stops
         formattedVariant.downItinerary!.sort(by: { $0.orderInRoute < $1.orderInRoute })

      }

      // For CircItinerary:
      if (rawVariant.circItinerary != nil) {

         // Change the temporary variable property to an empty array
         formattedVariant.circItinerary = []

         // For each connection,
         // convert the nested objects into a simplified RouteStop object
         for rawConnection in rawVariant.circItinerary!.connections {

            // Append new values to the temporary variable property directly
            formattedVariant.circItinerary!.append(
               Stop(
                  orderInRoute: rawConnection.orderNum,
                  publicId: rawConnection.busStop.publicId,
                  name: rawConnection.busStop.name,
                  direction: .circular,
                  lat: rawConnection.busStop.lat,
                  lng: rawConnection.busStop.lng
               )
            )

         }

         // Sort the stops
         formattedVariant.circItinerary!.sort(by: { $0.orderInRoute < $1.orderInRoute })

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
      }) ?? -1 // If the item does not exist, return default value -1

      // If a match is found...
      if (indexOfRouteInArray > 0) {
         return allRoutes[indexOfRouteInArray]
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
