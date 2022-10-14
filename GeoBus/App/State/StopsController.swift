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
class StopsController: ObservableObject {

   /* MARK: - Variables */

   private let storageKeyForAllStops: String = "stops_allStops"
   @Published var allStops: [Stop] = []

   private let storageKeyForLastUpdatedStops: String = "stops_lastUpdatedStops"
   private var lastUpdatedStops: String? = nil

   private let storageKeyForFavoriteStops: String = "stops_favoriteStops"
   @Published var favorites: [Stop] = []

   @Published var selectedStop: Stop?



   /* MARK: - INITIALIZER */

   // Retrieve data from UserDefaults on init.

   init() {
      // Unwrap and Decode all stops
      if let unwrappedAllStops = UserDefaults.standard.data(forKey: storageKeyForAllStops) {
         if let decodedAllStops = try? JSONDecoder().decode([Stop].self, from: unwrappedAllStops) {
            self.allStops = decodedAllStops
         }
      }
      // Unwrap lastUpdatedStops timestamp
      if let unwrappedLastUpdatedStops = UserDefaults.standard.string(forKey: storageKeyForLastUpdatedStops) {
         self.lastUpdatedStops = unwrappedLastUpdatedStops
      }
   }



   /* MARK: - Selectors */
   
   // Getters and Setters for published and private variables.

   private func select(stop: Stop) {
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


   func deselect() {
      self.selectedStop = nil
   }



   /* MARK: - Check for Updates from Carris API */

   // This function decides whether to update available routes
   // if they are outdated. For now, do this once a day.

   func update(forced: Bool = false) {
      Task {

         let formatter = ISO8601DateFormatter()
         
         if (lastUpdatedStops == nil || allStops.isEmpty || forced) {
            await fetchStopsFromAPI()
            let timestamp = formatter.string(from: Date.now)
            UserDefaults.standard.set(timestamp, forKey: storageKeyForLastUpdatedStops)
         } else {
            // Calculate time interval
            let formattedDateObj = formatter.date(from: lastUpdatedStops!)
            let secondsPassed = Int(formattedDateObj?.timeIntervalSinceNow ?? -1)

            if ( (secondsPassed * -1) > (86400 * 5) ) { // 86400 seconds * 5 = 5 days
               await fetchStopsFromAPI()
               let timestamp = formatter.string(from: Date.now)
               UserDefaults.standard.set(timestamp, forKey: storageKeyForLastUpdatedStops)
            }
         }

         // Retrieve favorites at app launch
         self.retrieveFavorites()

      }
   }



   /* MARK: - Retrieve Favourite Routes from iCloud KVS */

   // This function retrieves favorites from iCloud Key-Value-Storage.

   func retrieveFavorites() {

      // Get from iCloud
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.synchronize()

      let savedFavorites = iCloudKeyStore.array(forKey: storageKeyForFavoriteStops) as? [String] ?? []

      // Save to array
      for stopPublicId in savedFavorites {
         let stop = findStop(by: stopPublicId)
         if (stop != nil) {
            favorites.append(stop!)
         }
      }

   }



   /* MARK: - Save Favorite Routes to iCloud KVS */

   // This function saves a representation of the routes stored in the favorites array
   // to iCloud Key-Value-Store. This function should be called whenever a change
   // in favorites occurs, to ensure consistency across devices.

   func saveFavorites() {
      var favoritesToSave: [String] = []
      for favStop in favorites {
         favoritesToSave.append(favStop.publicId)
      }
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.set(favoritesToSave, forKey: storageKeyForFavoriteStops)
      iCloudKeyStore.synchronize()
   }



   /* MARK: - Toggle Route as Favorite */

   // This function marks a route as favorite if it is not,
   // and removes it from favorites if it is.

   func toggleFavorite(stop: Stop) {

      if let index = self.favorites.firstIndex(of: stop) {
         self.favorites.remove(at: index)
      } else {
         self.favorites.append(stop)
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

   func isFavourite(stop: Stop) -> Bool {
      return favorites.contains(stop)
   }



   /* MARK: - Fetch & Format Stops From Carris API */

   // This function first fetches the Routes List,
   // which is an object that contains all the available routes from the API.
   // The information for each Route is very short, so it is necessary to retrieve
   // the details for each route. Here, we only care about the publicy available routes.
   // After, for each route, it's details are formatted and transformed into a Route.

   func fetchStopsFromAPI() async {

      Analytics.shared.capture(event: .Stops_Sync_START)
      Appstate.shared.change(to: .loading, for: .stops)

      print("Fetching Stops: Starting...")

      do {
         // Request API Routes List
         var requestAPIStopsList = URLRequest(url: URL(string: "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.10/busstops")!)
         requestAPIStopsList.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIStopsList.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIStopsList.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIStopsList, rawResponseAPIStopsList) = try await URLSession.shared.data(for: requestAPIStopsList)
         let responseAPIStopsList = rawResponseAPIStopsList as? HTTPURLResponse

         // Check status of response
         if (responseAPIStopsList?.statusCode == 401) {
            Task {
               await CarrisAuthentication.shared.authenticate()
               await self.fetchStopsFromAPI()
            }
            return
         } else if (responseAPIStopsList?.statusCode != 200) {
            print(responseAPIStopsList as Any)
            throw Appstate.ModuleError.carris_unavailable
         }

         let decodedAPIStopsList = try JSONDecoder().decode([APIStop].self, from: rawDataAPIStopsList)

         // Define a temporary variable to store routes
         // before saving them to the device storage.
         var tempAllStops: [Stop] = []

         // For each available route in the API,
         for availableStop in decodedAPIStopsList {
            if (availableStop.isPublicVisible ?? false) {
               // Save the formatted route object in the allRoutes temporary variable
               tempAllStops.append(Stop(
                  publicId: availableStop.publicId ?? "0",
                  name: availableStop.name ?? "-",
                  lat: availableStop.lat ?? 0,
                  lng: availableStop.lng ?? 0,
                  orderInRoute: nil,
                  direction: nil
               ))
            }
         }

         // Finally, save the temporary variables into storage,
         // while removing the previous, old ones.
         self.allStops.removeAll()
         self.allStops.append(contentsOf: tempAllStops)
         if let encodedAllStops = try? JSONEncoder().encode(self.allStops) {
            UserDefaults.standard.set(encodedAllStops, forKey: storageKeyForAllStops)
         }

         print("Fetching Stops: Complete!")

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



   /* MARK: - Find Stop by Public ID */

   // This function searches for the provided routeNumber in all routes array,
   // and returns it if found. If not found, returns nil.

   func findStop(by stopPublicId: String) -> Stop? {

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



}
