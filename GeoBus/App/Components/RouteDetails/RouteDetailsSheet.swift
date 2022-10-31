//
//  RouteDetailsSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsSheet: View {
   
   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   @State var routeDirection: Int = 0
   @State var routeDirectionPicker: Int = 0
   
   
   var liveInfo: some View {
      
      VStack(spacing: 15) {
         
         SheetHeader(title: Text("Route Details"))
         
         HStack(spacing: 25) {
            RouteBadgeSquare(routeNumber: carrisNetworkController.activeRoute!.number)
               .frame(width: 80)
            Text(carrisNetworkController.activeRoute?.name ?? "-")
               .fontWeight(.bold)
               .foregroundColor(Color(.label))
            Spacer()
         }
         .padding()
         .background(Color("BackgroundSecondary"))
         .cornerRadius(10)
         
         HStack(spacing: 15) {
            RouteDetailsVehiclesQuantity(vehiclesQuantity: carrisNetworkController.activeVehicles.count)
            Button(action: {
               TapticEngine.impact.feedback(.heavy)
               carrisNetworkController.toggleFavoriteForActiveRoute()
            }) {
               RouteDetailsAddToFavorites()
            }
         }
         
      }
   }
   
   
   var stopsList: some View {
      
      VStack(spacing: 15) {
         
         if (carrisNetworkController.activeVariant?.circularItinerary != nil) {
            Chip(icon: Image(systemName: "repeat"), text: Text("This is a circular route."), color: Color(.systemBlue))
            ConnectionsList(connections: carrisNetworkController.activeVariant!.circularItinerary!)
            
         } else if (carrisNetworkController.activeVariant?.ascendingItinerary != nil && carrisNetworkController.activeVariant?.descendingItinerary != nil) {
            Picker("Direction", selection: $routeDirectionPicker) {
               Text("to: \(carrisNetworkController.activeVariant?.ascendingItinerary?.last?.stop.name ?? "-")").tag(0)
               Text("to: \(carrisNetworkController.activeVariant?.descendingItinerary?.last?.stop.name ?? "-")").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if (self.routeDirectionPicker == 0) {
               ConnectionsList(connections: carrisNetworkController.activeVariant!.ascendingItinerary!)
            } else {
               ConnectionsList(connections: carrisNetworkController.activeVariant!.descendingItinerary!)
            }
            
         } else if (carrisNetworkController.activeVariant?.ascendingItinerary != nil) {
            ConnectionsList(connections: carrisNetworkController.activeVariant!.ascendingItinerary!)
            
         } else if (carrisNetworkController.activeVariant?.descendingItinerary != nil) {
            ConnectionsList(connections: carrisNetworkController.activeVariant!.descendingItinerary!)
            
         }
         
      }
      
   }
   
   
   var body: some View {
      
      ScrollView(showsIndicators: true) {
         VStack(spacing: 5) {
            liveInfo
               .padding()
            Divider()
            if (carrisNetworkController.activeRoute!.variants.count > 1) {
               VariantPicker()
               Divider()
            }
            stopsList
               .padding()
         }
         .padding(.bottom, 30)
      }
      .background(Color("BackgroundPrimary"))
      
   }
   
}
