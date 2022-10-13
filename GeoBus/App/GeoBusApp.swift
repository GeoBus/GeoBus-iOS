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
   
   @StateObject private var stopsController = StopsController()
   @StateObject private var routesController = RoutesController()
   @StateObject private var vehiclesController = VehiclesController()
   @StateObject private var estimationsController = EstimationsController()
   
   @StateObject private var appstate = Appstate()
   @StateObject private var analytics = Analytics()
   @StateObject private var mapController = MapController()
   @StateObject private var carrisAuthController = CarrisAuthController()
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
            .environmentObject(self.appstate)
            .environmentObject(self.analytics)
            .environmentObject(self.mapController)
            .environmentObject(self.carrisNetworkController)
            .onAppear(perform: {
               // Pass references to Controllers
               self.mapController.receive(self.appstate, self.analytics)
               self.carrisAuthController.receive(self.appstate, self.analytics)
               self.carrisNetworkController.receive(self.appstate, self.analytics, self.carrisAuthController)
               // Update Carris network model
               self.carrisNetworkController.start()
               // Capture app open
               self.analytics.capture(event: .App_Session_Start)
            })
            .onReceive(updateIntervalTimer) { event in
               // Capture session continuation
               self.analytics.capture(event: .App_Session_Ping)
               // Update vehicles on timer call
               self.vehiclesController.update(scope: .summary)
            }
      }
   }
   
}
