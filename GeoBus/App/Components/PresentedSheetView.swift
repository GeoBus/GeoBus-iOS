//
//  PresentedSheetView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 22/10/2022.
//

import SwiftUI

struct PresentedSheetView: View {
   
   @ObservedObject private var sheetController = SheetController.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      switch sheetController.currentlyPresentedSheetView {
            
         case .carris_RouteSelector:
            SelectRouteSheet()
               .presentationDetents([.large])
               .presentationDragIndicator(.hidden)
            
         case .carris_RouteDetails:
            RouteDetailsSheet()
               .presentationDetents([.large])
               .presentationDragIndicator(.hidden)
            
         case .carris_stopSelector:
            StopSearchView()
               .presentationDetents([.medium])
               .presentationDragIndicator(.hidden)
            
         case .carris_vehicleDetails:
            CarrisVehicleSheetView()
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
               .onDisappear() {
                  carrisNetworkController.deselect([.vehicle])
               }
            
         case .carris_connectionDetails:
            ConnectionSheetView()
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
               .onDisappear() {
                  carrisNetworkController.deselect([.connection])
               }
            
         case .carris_stopDetails:
            StopSheetView()
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
               .onDisappear() {
                  carrisNetworkController.deselect([.stop])
               }
            
         case .none:
            EmptyView()
            
      }
   }
   
}
