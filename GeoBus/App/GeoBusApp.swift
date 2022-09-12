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
   @StateObject private var authentication = Authentication()
   @StateObject private var routesController = RoutesController()
   @StateObject private var vehiclesController = VehiclesController()

   let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(appstate)
            .environmentObject(authentication)
            .environmentObject(routesController)
            .environmentObject(vehiclesController)
            .onAppear(perform: {
               Task {
                  // Pass references to Appstate
                  authentication.receive(reference: appstate)
                  routesController.receive(reference: appstate)
                  vehiclesController.receive(reference: appstate)
                  // Initiate authentication
//                  await authentication.authenticate()
                  // Update available routes
                  await routesController.start()
               }
            })
            .onReceive(timer) { event in
               Task {
//                  await self.authentication.authenticate()
                  await vehiclesController.fetchVehiclesFromAPI()
               }
            }
      }
   }
}
