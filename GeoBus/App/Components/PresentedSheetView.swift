//
//  PresentedSheetView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 22/10/2022.
//

import SwiftUI

struct PresentedSheetView: View {
   
   @EnvironmentObject var appstate: Appstate
   
   var body: some View {
      switch appstate.currentlyPresentedSheetView {
         case .carris_RouteSelector:
            SelectRouteSheet()
         case .carris_RouteDetails:
            RouteDetailsSheet()
         case .carris_stopSelector:
            StopSearchView()
         case .carris_vehicleDetails:
            VehicleDetailsView()
         case .carris_connectionDetails:
//            ConnectionDetailsView()
            EmptyView()
         case .none:
            EmptyView()
      }
   }
   
}
