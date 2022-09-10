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

   @StateObject private var authentication = Authentication()
   @StateObject private var routesController = RoutesController()

   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(authentication)
            .environmentObject(routesController)
            .onAppear(perform: {
               Task {
                  // Initiate authentication
                  await authentication.authenticate()
                  // Update available routes
                  await routesController.updateAvailableRoutes()
               }
            })
      }
   }
}
