import SwiftUI

/* MARK: - GEOBUS */

@main
struct GeoBusApp: App {
   
   @StateObject private var appstate = Appstate.shared
   @StateObject private var mapController = MapController.shared
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   // @StateObject private var tcbNetworkController = TCBNetworkController.shared
   
   @StateObject private var carrisNetworkController = CarrisNetworkController()
   private let updateIntervalTimer = Timer.publish(every: 20 /* seconds */, on: .main, in: .common).autoconnect()
   
   var body: some Scene {
      WindowGroup {
         ContentView()
<<<<<<< HEAD
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
=======
            .environmentObject(appstate)
            .environmentObject(mapController)
            .environmentObject(carrisNetworkController)
            .onAppear(perform: {
>>>>>>> production
               Analytics.shared.capture(event: .App_Session_Start)
            })
            .onReceive(updateIntervalTimer) { event in
               carrisNetworkController.refresh()
               Analytics.shared.capture(event: .App_Session_Ping)
<<<<<<< HEAD
               // Update vehicles on timer call
//               self.vehiclesController.update(scope: .summary)
               Task {
                  await vehiclesController.fetchVehiclesFromCarrisAPI()
               }
=======
>>>>>>> production
            }
      }
   }
   
}
