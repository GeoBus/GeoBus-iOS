//
//  RouteDetailsSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsSheet: View {
   
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   @Binding var showRouteDetailsSheet: Bool
   
   @State var routeDirection: Int = 0
   @State var routeDirectionPicker: Int = 0
   
   
   var liveInfo: some View {
      
      VStack(spacing: 15) {
         
         SheetHeader(title: Text("Route Details"), toggle: $showRouteDetailsSheet)
         
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
            RouteDetailsVehiclesQuantity(vehiclesQuantity: carrisNetworkController.allVehicles.count)
            Button(action: {
               TapticEngine.impact.feedback(.heavy)
               // self.carrisNetworkController.toggleFavorite(route: self.carrisNetworkController.selectedRoute!)
            }) {
               RouteDetailsAddToFavorites()
            }
         }
         
      }
   }
   
   
   var stopsList: some View {
      
      VStack(spacing: 15) {
         
         if (carrisNetworkController.activeVariant?.circularItinerary != nil) {
            RouteCircularVariantInfo()
            ConnectionsList(connections: carrisNetworkController.activeVariant!.circularItinerary!)
            
         } else if (carrisNetworkController.activeVariant?.ascendingItinerary != nil && carrisNetworkController.activeVariant?.descendingItinerary != nil) {
            Picker("Direction", selection: $routeDirectionPicker) {
               Text(carrisNetworkController.activeVariant?.ascendingItinerary?.last?.stop.name ?? "-").tag(0)
               Text(carrisNetworkController.activeVariant?.descendingItinerary?.last?.stop.name ?? "-").tag(1)
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
      
      ScrollView(.vertical, showsIndicators: true) {
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
