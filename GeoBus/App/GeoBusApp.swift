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
   
   @StateObject private var appstate = Appstate()
   @StateObject private var analytics = Analytics()
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
            .environmentObject(analytics)
            .environmentObject(mapController)
            .environmentObject(authentication)
            .environmentObject(stopsController)
            .environmentObject(routesController)
            .environmentObject(vehiclesController)
            .environmentObject(estimationsController)
            .onAppear(perform: {
               // Pass references to Controllers
               self.mapController.receive(state: appstate)
               self.authentication.receive(state: appstate)
               self.stopsController.receive(state: appstate, auth: authentication)
               self.routesController.receive(state: appstate, auth: authentication)
               self.vehiclesController.receive(state: appstate, auth: authentication)
               self.estimationsController.receive(state: appstate, auth: authentication)
               // Update available stops & routes
               self.stopsController.update()
               self.routesController.update()
               self.vehiclesController.update(scope: .summary)
               // Capture app open
               self.analytics.capture(event: .App_Session_Start)
            })
            .onReceive(refreshVehiclesTimer) { event in
               // Capture session continuation
               self.analytics.capture(event: .App_Session_Ping)
               // Update vehicles on timer call
               self.vehiclesController.update(scope: .summary)
            }
      }
   }
   
}
