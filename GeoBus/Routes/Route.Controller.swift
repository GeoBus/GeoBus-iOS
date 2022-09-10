//
//  Route.Controller.swift
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

   /* MARK: - Settings */

   private var endpoint = "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.9/Routes"


   /* MARK: - Storage */

   private var authentication = Authentication()

   @Stored(in: .allRoutes) var allRoutes

   @Published var selectedRoute: RouteFinal?
   @Published var selectedRouteVariant: RouteVariantFinal?
   @Published var selectedRouteVariantStop: IdentifiablePlace?

   @Published var selectedRouteVariantStopAnnotations: [RouteVariantStopAnnotation] = []
   @Published var selectedStops: [IdentifiablePlace] = []


   @StoredValue(key: "lastUpdatedRoutes")
   var lastUpdateRoutes: String? = nil

   /* * */


   /* MARK: - Select Route */

   // Discover the Route kind by analysing the route number.

   func select(route: RouteFinal) {
      self.selectedRoute = route
      self.select(variant: route.variants[0])
   }

   func select(byRouteNumber routeNumber: String) -> Bool {

      // Find index of route matching requested routeNumber
      let indexOfRouteInArray = allRoutes.firstIndex(where: { (route) -> Bool in
         route.number == routeNumber // test if this is the item we're looking for
      }) ?? -1 // If the item does not exist, return default value -1

      // If a match is found
      if indexOfRouteInArray > 0 {
         self.select(route: allRoutes[indexOfRouteInArray])
         return true

      } else { return false }

   }

   func select(variant: RouteVariantFinal) {
      self.selectedRouteVariant = variant
      self.setSelectedRouteVariantStopAnnotations()
   }

   func select(stop: IdentifiablePlace?) {
      self.selectedRouteVariantStop = stop
   }


   /* MARK: - Set Selected Route Variant Stop Annotations */

   // Populate array of map annotations for bus stops.
   // RouteVariantStop is transformed into RouteVariantStopAnnotation
   // to be displayed in MKMapView.

   func setSelectedRouteVariantStopAnnotations() {

//      var formattedAnnotations: [RouteVariantStopAnnotation] = []
      var formattedAnnotations: [IdentifiablePlace] = []

      if (selectedRoute != nil && selectedRouteVariant != nil) {

         if (selectedRouteVariant!.upItinerary != nil) {
            for stop in selectedRouteVariant!.upItinerary! {
               formattedAnnotations.append(
//                  RouteVariantStopAnnotation(
//                     originalStop: stop,
//                     latitude: stop.lat,
//                     longitude: stop.lng
//                  )
                  IdentifiablePlace(lat: stop.lat, long: stop.lng)
               )
            }
         }

         if (selectedRouteVariant!.downItinerary != nil) {
            for stop in selectedRouteVariant!.downItinerary! {
               formattedAnnotations.append(
//                  RouteVariantStopAnnotation(
//                     originalStop: stop,
//                     latitude: stop.lat,
//                     longitude: stop.lng
//                  )
                  IdentifiablePlace(lat: stop.lat, long: stop.lng)
               )
            }
         }

         if (selectedRouteVariant!.circItinerary != nil) {
            for stop in selectedRouteVariant!.circItinerary! {
               formattedAnnotations.append(
//                  RouteVariantStopAnnotation(
//                     originalStop: stop,
//                     latitude: stop.lat,
//                     longitude: stop.lng
//                  )
                  IdentifiablePlace(lat: stop.lat, long: stop.lng)
               )
            }
         }

      }

//      self.selectedRouteVariantStopAnnotations = formattedAnnotations
      self.selectedStops = formattedAnnotations

   }


   /* MARK: - Update Available Routes from Carris API */

   // This function decides whether to update available routes
   // if they are outdated. For now, do this once a day.

   func updateAvailableRoutes() async {

      if (lastUpdateRoutes != nil) {
         // Check for time difference. Once a day sounds OK
      }

      await fetchRoutesFromAPI()

   }


   /* MARK: - Fetch & Format Routes From Carris API */

   // This function first fetches the Routes List,
   // which is an object that contains all the available routes from the API.
   // The information for each Route is very short, so it is necessary to retrieve
   // the details for each route. Here, we only care about the publicy available routes.
   // After, for each route, it's details are formatted and transformed into a Route.

   func fetchRoutesFromAPI() async {

      // Check if Authentication is properly set
      if (authentication.authToken != nil) {

         do {
            // Request API Routes List
            var requestAPIRoutesList = URLRequest(url: URL(string: endpoint)!)
            requestAPIRoutesList.addValue("application/json", forHTTPHeaderField: "Content-Type")
            requestAPIRoutesList.addValue("application/json", forHTTPHeaderField: "Accept")
            requestAPIRoutesList.setValue("Bearer \(authentication.authToken!)", forHTTPHeaderField: "Authorization")
            let (rawRequestAPIRoutesList, _) = try await URLSession.shared.data(for: requestAPIRoutesList)
            let decodedAPIRoutesList = try JSONDecoder().decode([APIRoutesList].self, from: rawRequestAPIRoutesList)

            // Define a temporary variable to store routes
            // before saving them to the device storage.
            var tempAllRoutes: [RouteFinal] = []

            // For each available route in the API,
            for availableRoute in decodedAPIRoutesList {

               if (availableRoute.isPublicVisible) {

                  // Request Route Detail for .routeNumber
                  var requestAPIRouteDetail = URLRequest(url: URL(string: endpoint + "/\(availableRoute.routeNumber)")!)
                  requestAPIRouteDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
                  requestAPIRouteDetail.addValue("application/json", forHTTPHeaderField: "Accept")
                  requestAPIRouteDetail.setValue("Bearer \(authentication.authToken!)", forHTTPHeaderField: "Authorization")
                  let (rawRequestAPIRouteDetail, _) = try await URLSession.shared.data(for: requestAPIRouteDetail)
                  let decodedAPIRouteDetail = try JSONDecoder().decode(APIRoute.self, from: rawRequestAPIRouteDetail)

                  // Define a temporary variable to store formatted route variants
                  var formattedRouteVariants: [RouteVariantFinal] = []

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
                  let formattedRoute = RouteFinal(
                     number: decodedAPIRouteDetail.routeNumber,
                     name: decodedAPIRouteDetail.name,
                     kind: getRouteKind(byRouteNumber: decodedAPIRouteDetail.routeNumber),
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

            print("Route Fetching Complete")

         } catch {
            print("************")
            print("Error: \(error)")
            print("************")
         }

      }

   }


   /* MARK: - Get Route Kind */

   // Discover the Route kind by analysing the route number.

   func getRouteKind(byRouteNumber: String) -> RouteKind {

      if (byRouteNumber.suffix(1) == "B") {
         // Neighborhood buses end with "B"
         return .neighborhood

      } else if (byRouteNumber.suffix(1) == "E") {
         // Trams and Elevators end with "E"
         if (byRouteNumber.prefix(1) == "5") {
            // and Elevators start with "5"
            return .elevator
         } else {
            // All other options starting with "E" are trams
            return .tram
         }

      } else if (byRouteNumber.prefix(1) == "2") {
         // Night service starts with "2"
         return .night

      } else {
         // All other options are regular service
         return .regular

      }

   }


   /* MARK: - Format Route Variants */

   // Parse and simplify the data model for variants

   func formatRawRouteVariant(rawVariant: APIRouteVariant, isCircular: Bool) -> RouteVariantFinal {

      // Create an temporary variable to store the final RouteVariant
      var formattedVariant = RouteVariantFinal(
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
               RouteVariantStopFinal(
                  orderInRoute: rawConnection.orderNum,
                  publicId: rawConnection.busStop.publicId,
                  name: rawConnection.busStop.name,
                  direction: .ascending,
                  lastStopOnVoyage: "teste",
                  lat: rawConnection.busStop.lat,
                  lng: rawConnection.busStop.lng
               )
            )

         }

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
               RouteVariantStopFinal(
                  orderInRoute: rawConnection.orderNum,
                  publicId: rawConnection.busStop.publicId,
                  name: rawConnection.busStop.name,
                  direction: .descending,
                  lastStopOnVoyage: "teste",
                  lat: rawConnection.busStop.lat,
                  lng: rawConnection.busStop.lng
               )
            )

         }

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
               RouteVariantStopFinal(
                  orderInRoute: rawConnection.orderNum,
                  publicId: rawConnection.busStop.publicId,
                  name: rawConnection.busStop.name,
                  direction: .circular,
                  lastStopOnVoyage: "teste",
                  lat: rawConnection.busStop.lat,
                  lng: rawConnection.busStop.lng
               )
            )

         }

      }

      // Finally, return the temporary variable to the caller
      return formattedVariant

   }

}
