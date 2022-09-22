//
//  GeoBusApp.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import PostHog

@main
struct GeoBusApp: App {

   /* MARK: - POSTHOG ANALYTICS */

   private let posthog: PHGPostHog?

   init() {
      if let posthogApiKey = Bundle.main.infoDictionary?["POSTHOG_API_KEY"] as? String {
         let configuration = PHGPostHogConfiguration(apiKey: posthogApiKey)
         configuration.shouldUseLocationServices = false
         configuration.flushAt = 1
         configuration.flushInterval = 10
         configuration.maxQueueSize = 1000
         configuration.captureApplicationLifecycleEvents = false
         configuration.shouldUseBluetooth = false
         configuration.recordScreenViews = false
         configuration.captureInAppPurchases = false
         configuration.capturePushNotifications = false
         configuration.captureDeepLinks = false
         configuration.shouldSendDeviceID = true
         PHGPostHog.setup(with: configuration)
         self.posthog = PHGPostHog.shared()
      } else {
         self.posthog = nil
      }
   }


   /* MARK: - GEOBUS */

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
               appstate.receive(analytics: posthog)
               mapController.receive(state: appstate)
               authentication.receive(state: appstate)
               stopsController.receive(state: appstate, auth: authentication)
               routesController.receive(state: appstate, auth: authentication)
               vehiclesController.receive(state: appstate, auth: authentication)
               estimationsController.receive(state: appstate, auth: authentication)
               // Update available stops & routes
               stopsController.update()
               routesController.update()
               // Capture app open
               appstate.capture(event: "GeoBus-App-Start")
            })
            .onReceive(refreshVehiclesTimer) { event in
               Task {
                  // Capture session continuation
                  appstate.capture(event: "GeoBus-App-SessionPing")
                  // Update vehicles on timer call
                  await vehiclesController.fetchVehiclesFromAPI()
               }
            }
      }
   }
}
