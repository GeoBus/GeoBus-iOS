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
            
         case .RouteSelector:
            SelectRouteSheet()
               .presentationDetents([.large])
               .presentationDragIndicator(.hidden)
            
         case .RouteDetails:
            RouteDetailsSheet()
               .presentationDetents([.large])
               .presentationDragIndicator(.hidden)
            
         case .StopSelector:
            StopSearchView()
               .presentationDetents([.medium])
               .presentationDragIndicator(.hidden)
            
         case .StopDetails:
            StopSheetView()
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
               .onDisappear() {
                  carrisNetworkController.deselect([.stop])
               }
            
         case .ConnectionDetails:
            ConnectionSheetView()
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
               .onDisappear() {
                  carrisNetworkController.deselect([.connection])
               }
            
         case .VehicleDetails:
            CarrisVehicleSheetView()
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
               .onDisappear() {
                  carrisNetworkController.deselect([.vehicle])
               }
            
         case .none:
            EmptyView()
            
      }
   }
   
}
