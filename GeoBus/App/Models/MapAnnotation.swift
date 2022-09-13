//
//  MapAnnotation.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation
import MapKit
import SwiftUI

struct GenericMapAnnotation: Identifiable {

   let id = UUID()
   let location: CLLocationCoordinate2D
   let format: Format

   // For stops
   var stop: RouteVariantStop?

   // For vehicles
   var vehicle: Vehicle?

   enum Format {
      case stop
      case vehicle
   }

   init(lat: Double, lng: Double, format: Format, stop: RouteVariantStop) {
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.stop = stop
      self.vehicle = nil
   }

   init(lat: Double, lng: Double, format: Format, vehicle: Vehicle) {
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.stop = nil
      self.vehicle = vehicle
   }

}







struct StopAnnotationView: View {

   @EnvironmentObject var routesController: RoutesController
   
   var stop: RouteVariantStop

   var body: some View {
      // Wrap the marker image in a View to configure
      // touch target size and action on tap in one place.
      VStack {
         if (routesController.selectedRouteVariantStop != nil
             && routesController.selectedRouteVariantStop!.id == stop.id) {
            Image("GreenInfo")
         } else {
            switch (stop.direction) {
               case .ascending:
                  Image("PinkArrowUp")
               case .descending:
                  Image("OrangeArrowDown")
               case .circular:
                  Image("BlueArrowRight")
            }
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .onTapGesture {
         if (routesController.selectedRouteVariantStop != nil) {
//            routesController.deselectStop()
         } else {
            routesController.select(stop: stop)
         }
      }

   }

}





struct VehicleAnnotationView: View {

   let vehicle: Vehicle

   @State var showDetails: Bool = false

   var body: some View {
      // Wrap the marker image in a View to configure
      // touch target size and action on tap in one place.
      VStack {

         if (showDetails) {
            Text("Details are visisble!")
               .frame(width: 40, height: 40, alignment: .center)
               .background(Rectangle())
         }

         VStack {

            switch (vehicle.kind) {
               case .tram:
                  Image("Tram-Active")
               case .neighborhood:
                  Image("RegularService-Active")
               case .night:
                  Image("RegularService-Active")
               case .elevator:
                  Image("RegularService-Active")
               case .regular:
                  Image("RegularService-Active")
            }
         }
         .frame(width: 40, height: 40, alignment: .center)
         .rotationEffect(.radians(vehicle.angleInRadians))
         .onTapGesture {
            self.showDetails = !showDetails
         }
      }

   }

}



struct VehicleAnnotationViewShowAfterTap: View {

   let vehicle: Vehicle

   var body: some View {

      VStack(alignment: .leading) {
         HStack {
            RouteBadgePill(routeNumber: vehicle.routeNumber)
            Text("to")
               .font(.footnote)
               .foregroundColor(Color(.secondaryLabel))
            Text(vehicle.lastStopOnVoyageName)
               .font(.body)
               .fontWeight(.medium)
               .lineLimit(1)
               .foregroundColor(Color(.label))
         }
         HStack {
            Text(
               "Last seen \(vehicle.lastGpsTime) seconds ago"
               + " (Bus #\(vehicle.busNumber))")
            .font(.footnote)
            .foregroundColor(Color(.secondaryLabel))
            .padding(.top, 4)
         }
      }

   }


   func getTimeInterval(for eta: String) -> String {

      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

      let now = Date()
      let estimation = formatter.date(from: eta) ?? now

      let seconds = now.timeIntervalSince(estimation)

      return "\( Int(seconds) ) sec"

   }

}
