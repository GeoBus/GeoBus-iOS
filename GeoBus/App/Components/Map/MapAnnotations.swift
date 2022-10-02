//
//  MapAnnotation.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation
import MapKit
import SwiftUI


struct GenericMapAnnotation: Identifiable, Equatable {
   static func == (lhs: GenericMapAnnotation, rhs: GenericMapAnnotation) -> Bool {
      lhs.location.latitude == rhs.location.latitude && lhs.location.longitude == rhs.location.longitude
   }


   let id: String
   var location: CLLocationCoordinate2D
   let format: Format

   enum Format {
      case stop
      case vehicle
      case singleStop
   }

   // For Stops
   var stop: Stop?

   init(lat: Double, lng: Double, format: Format, stop: Stop) {
      self.id = stop.publicId
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.stop = stop
      self.vehicle = nil
   }

   // For Vehicles
   var vehicle: VehicleSummary?

   init(lat: Double, lng: Double, format: Format, vehicle: VehicleSummary) {
      self.id = vehicle.busNumber
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.stop = nil
      self.vehicle = vehicle
   }

}







struct StopAnnotationView: View {

   var stop: Stop

   let isPresentedOnAppear: Bool
   @State private var isPresented: Bool = false
   @State private var viewSize = CGSize()


   var body: some View {
      Button(action: {
         self.isPresented = !self.isPresented
         TapticEngine.impact.feedback(.light)
      }) {
         if (isPresented) {
            Image("GreenInfo")
         } else {
            switch (stop.direction) {
               case .ascending:
                  Image("PinkArrowUp")
               case .descending:
                  Image("OrangeArrowDown")
               case .circular:
                  Image("BlueArrowRight")
               case .none:
                  Image("BlueArrowRight")
            }
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .onAppear() {
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isPresented = self.isPresentedOnAppear
         }
      }
      .sheet(isPresented: $isPresented) {
         VStack(alignment: .leading) {
            StopDetailsView(
               canToggle: false,
               publicId: stop.publicId,
               name: stop.name,
               orderInRoute: stop.orderInRoute,
               direction: stop.direction
            )
            .padding(.bottom, 20)
            Disclaimer()
               .padding(.horizontal)
               .padding(.bottom, 10)
         }
         .readSize { size in
            viewSize = size
         }
         .presentationDetents([.height(viewSize.height)])
      }
   }

}





struct VehicleAnnotationView: View {

   let vehicle: VehicleSummary

   let isPresentedOnAppear: Bool
   @State private var isPresented: Bool = false
   @State private var viewSize = CGSize()


   var body: some View {
      Button(action: {
         self.isPresented = true
         TapticEngine.impact.feedback(.light)
      }) {
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
      }
      .frame(width: 40, height: 40, alignment: .center)
      .rotationEffect(.radians(vehicle.angleInRadians))
      .sheet(isPresented: $isPresented) {
         VStack(alignment: .leading) {
            VehicleDetailsView(
               busNumber: vehicle.busNumber,
               routeNumber: vehicle.routeNumber,
               lastGpsTime: vehicle.lastGpsTime
            )
            .padding(.bottom, 20)
            Disclaimer()
               .padding(.horizontal)
               .padding(.bottom, 10)
         }
         .readSize { size in
            viewSize = size
         }
         .presentationDetents([.height(viewSize.height)])
      }
   }

}
