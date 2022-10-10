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
   var vehicle: Vehicle?
   let busNumber: Int?
   
   init(lat: Double, lng: Double, format: Format, busNumber: Int, vehicle: Vehicle) {
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
         StopDetailsView(stop: self.stop)
      }
   }
   
}





struct VehicleAnnotationView: View {
   
   let vehicle: Vehicle
   
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
               case .none:
                  Rectangle()
                     .background(Color.clear)
            }
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .rotationEffect(.radians(vehicle.angleInRadians ?? 0))
      .sheet(isPresented: $isPresented) {
         VehicleInfoSheet(busNumber: vehicle.busNumber)
      }
   }
   
}
