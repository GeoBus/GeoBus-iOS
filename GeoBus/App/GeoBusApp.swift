import SwiftUI

/* MARK: - GEOBUS */

@main
struct GeoBusApp: App {
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   // @ObservedObject private var tcbNetworkController = TCBNetworkController.shared
   
   private let updateIntervalTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   
   var body: some Scene {
      WindowGroup {
         ContentView()
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
