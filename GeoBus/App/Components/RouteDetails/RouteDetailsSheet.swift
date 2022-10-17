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
//               self.carrisNetworkController.toggleFavorite(route: self.carrisNetworkController.selectedRoute!)
            }) {
               RouteDetailsAddToFavorites()
            }
         }

      }
   }


   var stopsList: some View {

      VStack(spacing: 15) {

         if (carrisNetworkController.activeVariant!.itineraries[0].direction == .circular) {
            RouteCircularVariantInfo()
//            StopsList(stops: carrisNetworkController.selectedVariant!.itineraries[0])
         } else {
            Picker("Direction", selection: $routeDirectionPicker) {
               Text("to: \(carrisNetworkController.getTerminalStopNameForVariant(variant: carrisNetworkController.activeVariant!, direction: .ascending))").tag(0)
               Text("to: \(carrisNetworkController.getTerminalStopNameForVariant(variant: carrisNetworkController.activeVariant!, direction: .descending))").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

//            if (self.routeDirectionPicker == 0) {
//               StopsList(stops: carrisNetworkController.selectedVariant!.upItinerary ?? [])
//            } else {
//               StopsList(stops: carrisNetworkController.selectedVariant!.downItinerary ?? [])
//            }
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
