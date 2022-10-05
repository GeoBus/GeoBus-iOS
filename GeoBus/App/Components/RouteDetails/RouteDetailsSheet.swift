//
//  RouteDetailsSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsSheet: View {

   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @Binding var showRouteDetailsSheet: Bool

   @State var routeDirection: Int = 0
   @State var routeDirectionPicker: Int = 0


   var liveInfo: some View {

      VStack(spacing: 15) {

         SheetHeader(title: Text("Route Details"), toggle: $showRouteDetailsSheet)

         HStack(spacing: 25) {
            RouteBadgeSquare(routeNumber: routesController.selectedRoute!.number)
               .frame(width: 80)
            Text(routesController.selectedRoute?.name ?? "-")
               .fontWeight(.bold)
               .foregroundColor(Color(.label))
            Spacer()
         }
         .padding()
         .background(Color("BackgroundSecondary"))
         .cornerRadius(10)

         HStack(spacing: 15) {
            RouteDetailsVehiclesQuantity(vehiclesQuantity: vehiclesController.vehicles.count)
            Button(action: {
               TapticEngine.impact.feedback(.heavy)
               self.routesController.toggleFavorite(route: self.routesController.selectedRoute!)
            }) {
               RouteDetailsAddToFavorites()
            }
         }

      }
   }


   var stopsList: some View {

      VStack(spacing: 15) {

         if (routesController.selectedVariant!.isCircular) {
            RouteCircularVariantInfo()
            StopsList(stops: routesController.selectedVariant!.circItinerary!)

         } else {
            Picker("Direction", selection: $routeDirectionPicker) {
               Text("to: \(routesController.getTerminalStopNameForVariant(variant: routesController.selectedVariant!, direction: .ascending))").tag(0)
               Text("to: \(routesController.getTerminalStopNameForVariant(variant: routesController.selectedVariant!, direction: .descending))").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

            if (self.routeDirectionPicker == 0) {
               StopsList(stops: routesController.selectedVariant!.upItinerary ?? [])
            } else {
               StopsList(stops: routesController.selectedVariant!.downItinerary ?? [])
            }
         }

      }

   }


   var body: some View {

      ScrollView(.vertical, showsIndicators: true) {
         VStack(spacing: 5) {
            liveInfo
               .padding()
            Divider()
            if (routesController.selectedRoute!.variants.count > 1) {
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
