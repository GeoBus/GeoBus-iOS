//
//  RouteDetailsSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteDetailsSheet: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @Binding var showRouteDetailsSheet: Bool

   @State var routeDirection: Int = 0
   @State var routeDirectionPicker: Int = 0


   var liveInfo: some View {

      VStack(spacing: 15) {

         SheetHeader(title: Text("Route Details"), toggle: $showRouteDetailsSheet)

         HStack(spacing: 15) {
            RouteBadgeSquare(route: routesController.selectedRoute!)
               .frame(width: 80)
            Text("route variant name")
               .foregroundColor(Color(.label))
               .padding(.leading)
            Spacer()
         }
         .padding()
         .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color(.systemBackground))
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

         if (routesController.selectedRouteVariant!.isCircular) {
            RouteCircularVariantInfo()
            StopsList(stops: routesController.selectedRouteVariant!.circItinerary!)

         } else {
            Picker("Direction", selection: $routeDirectionPicker) {
               Text("to: \(routesController.getTerminalStopNameForVariant(variant: routesController.selectedRouteVariant!, direction: .ascending))").tag(0)
               Text("to: \(routesController.getTerminalStopNameForVariant(variant: routesController.selectedRouteVariant!, direction: .descending))").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())

            if (self.routeDirectionPicker == 0) {
               StopsList(stops: routesController.selectedRouteVariant!.upItinerary!)
            } else {
               StopsList(stops: routesController.selectedRouteVariant!.downItinerary!)
            }
         }

      }

   }


   var body: some View {

      ScrollView(.vertical, showsIndicators: true) {

         VStack(spacing: 20) {

            liveInfo
               .padding(.horizontal)

            Divider()

            if (routesController.selectedRoute!.variants.count > 1) {
               RouteVariantPicker()
               Divider()
            }

            stopsList
               .padding(.horizontal)

         }

      }
      .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
//      .edgesIgnoringSafeArea(.bottom)

   }
}
