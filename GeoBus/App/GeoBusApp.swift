//
//  GeoBusApp.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI

@main
struct GeoBusApp: App {

   @StateObject private var appstate = Appstate()
   @StateObject private var mapController = MapController()
   @StateObject private var authentication = Authentication()
   @StateObject private var stopsController = StopsController()
   @StateObject private var routesController = RoutesController()
   @StateObject private var vehiclesController = VehiclesController()
   @StateObject private var estimationsController = EstimationsController()

   let refreshVehiclesTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()

   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(appstate)
            .environmentObject(mapController)
            .environmentObject(authentication)
            .environmentObject(stopsController)
            .environmentObject(routesController)
            .environmentObject(vehiclesController)
            .environmentObject(estimationsController)
            .onAppear(perform: {
               // Pass references to Controllers
               authentication.receive(state: appstate)
               stopsController.receive(state: appstate, auth: authentication)
               routesController.receive(state: appstate, auth: authentication)
               vehiclesController.receive(state: appstate, auth: authentication)
               estimationsController.receive(state: appstate, auth: authentication)
               // Update available stops & routes
               stopsController.update()
               routesController.update()
            })
            .onReceive(refreshVehiclesTimer) { event in
               Task {
                  // Update vehicles on timer call
                  await vehiclesController.fetchVehiclesFromAPI()
               }
            }
      }
   }
}
