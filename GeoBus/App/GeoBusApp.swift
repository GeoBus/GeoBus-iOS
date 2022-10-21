import SwiftUI

/* MARK: - GEOBUS */

@main
struct GeoBusApp: App {
   
   @StateObject private var appstate = Appstate.shared
   @StateObject private var mapController = MapController.shared
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   // @StateObject private var tcbNetworkController = TCBNetworkController.shared
   
   private let updateIntervalTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   
   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(appstate)
            .environmentObject(mapController)
            .environmentObject(carrisNetworkController)
            .onAppear(perform: {
               Analytics.shared.capture(event: .App_Session_Start)
            })
            .onReceive(updateIntervalTimer) { event in
               carrisNetworkController.refresh()
               Analytics.shared.capture(event: .App_Session_Ping)
            }
      }
   }
   
}
