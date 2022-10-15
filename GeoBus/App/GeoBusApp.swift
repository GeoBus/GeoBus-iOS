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
   
   /* MARK: - GEOBUS */
   
   @StateObject private var appstate = Appstate.shared
   @StateObject private var mapController = MapController()
   
   @StateObject private var stopsController = StopsController()
   @StateObject private var routesController = RoutesController()
   @StateObject private var vehiclesController = VehiclesController()
   @StateObject private var estimationsController = EstimationsController()
   
   @StateObject private var carrisNetworkController = CarrisNetworkController()
   private let updateIntervalTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   
   var body: some Scene {
      WindowGroup {
         ContentView()
            // OLD
            .environmentObject(stopsController)
            .environmentObject(routesController)
            .environmentObject(vehiclesController)
            .environmentObject(estimationsController)
            // NEW
            .environmentObject(self.mapController)
//            .environmentObject(self.carrisNetworkController)
            .onAppear(perform: {
               // Update Carris network model
//               self.carrisNetworkController.start()
               self.routesController.update()
               // Capture app open
               Analytics.shared.capture(event: .App_Session_Start)
            })
            .onReceive(updateIntervalTimer) { event in
               // Capture session continuation
               Analytics.shared.capture(event: .App_Session_Ping)
               // Update vehicles on timer call
//               self.vehiclesController.update(scope: .summary)
               Task {
                  await vehiclesController.fetchVehiclesFromCarrisAPI()
               }
            }
      }
   }
   
}
