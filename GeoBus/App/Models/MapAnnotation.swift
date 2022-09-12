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
   
   var direction: RouteVariantDirection

   var body: some View {
      // Wrap the marker image in a View to configure
      // touch target size and action on tap in one place.
      VStack {
         switch (direction) {
            case .ascending:
               Image("PinkArrowUp")
            case .descending:
               Image("OrangeArrowDown")
            case .circular:
               Image("BlueArrowRight")
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
   }

}
