import SwiftUI

/* MARK: - GEOBUS */

@main
struct GeoBusApp: App {
   
   @StateObject private var appstate = Appstate.shared
   @StateObject private var mapController = MapController()
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   
   private let updateIntervalTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   
   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(appstate)
            .environmentObject(mapController)
            .environmentObject(carrisNetworkController)
            .onAppear(perform: {
               Analytics.shared.capture(event: .App_Session_Start) // Capture app open
            })
            .onReceive(updateIntervalTimer) { event in
               carrisNetworkController.updateVehicles() // Update vehicles on timer call
               Analytics.shared.capture(event: .App_Session_Ping) // Capture session continuation
            }
      }
   }
   
}
