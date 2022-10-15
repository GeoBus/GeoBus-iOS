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
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.stop = stop
      self.vehicle = nil
      self.busNumber = nil
   }
   
   // For Vehicles
   var vehicle: VehicleSummary?
   let busNumber: Int?
   
   init(lat: Double, lng: Double, format: Format, busNumber: Int, vehicle: VehicleSummary) {
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.stop = nil
      self.vehicle = vehicle
      self.busNumber = busNumber
   }
   
}







struct StopAnnotationView: View {
   
   var stop: Stop
   
   let isPresentedOnAppear: Bool
   @State private var isPresented: Bool = false
   @State private var isAnnotationSelected: Bool = false
   
   
   var body: some View {
      Button(action: {
         self.isPresented = !self.isPresented
         self.isAnnotationSelected = self.isPresented
         TapticEngine.impact.feedback(.light)
      }) {
         StopIcon(
            orderInRoute: self.stop.orderInRoute ?? 0,
            direction: self.stop.direction ?? .circular,
            isSelected: self.isAnnotationSelected
         )
      }
      .frame(width: 40, height: 40, alignment: .center)
      .onAppear() {
         if (self.isPresentedOnAppear) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               self.isPresented = true
            }
         }
      }
      .sheet(isPresented: $isPresented, onDismiss: {
         withAnimation(.easeInOut(duration: 0.1)) {
            self.isAnnotationSelected = false
         }
      }) {
         StopDetailsView(stop: self.stop)
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
      }
   }
   
}
