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
      case carris_stop
      case carris_vehicle
      case carris_connection
   }
   
   // For Stops
   var carris_stop: Stop_NEW?
   
   init(lat: Double, lng: Double, format: Format, stop: Stop_NEW) {
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.carris_stop = stop
      self.carris_vehicle = nil
      self.carris_connection = nil
      self.busNumber = nil
   }
   
   
   // For Connections
   var carris_connection: Connection_NEW?
   
   init(lat: Double, lng: Double, format: Format, connection: Connection_NEW) {
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.carris_stop = nil
      self.carris_connection = connection
      self.carris_vehicle = nil
      self.busNumber = nil
   }
   
   // For Vehicles
   var carris_vehicle: CarrisVehicle?
   let busNumber: Int?
   
   init(lat: Double, lng: Double, format: Format, busNumber: Int, vehicle: CarrisVehicle) {
      self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      self.format = format
      self.carris_stop = nil
      self.carris_vehicle = vehicle
      self.carris_connection = nil
      self.busNumber = busNumber
   }
   
}







struct CarrisStopAnnotationView: View {
   
   var stop: Stop_NEW
   
   @State private var isAnnotationSelected: Bool = false
   
   
   var body: some View {
      Button(action: {
         self.isAnnotationSelected = true
         TapticEngine.impact.feedback(.light)
      }) {
         StopIcon(
            orderInRoute: 0,
            direction: .circular,
            isSelected: self.isAnnotationSelected
         )
      }
      .frame(width: 40, height: 40, alignment: .center)
      .onAppear() {
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnnotationSelected = true
         }
      }
      .sheet(isPresented: $isAnnotationSelected, onDismiss: {
         withAnimation(.easeInOut(duration: 0.1)) {
            self.isAnnotationSelected = false
         }
      }) {
         Text("StopIcon")
      }
   }
   
}


struct CarrisConnectionAnnotationView: View {
   
   var connection: Connection_NEW
   
   @State private var isAnnotationSelected: Bool = false
   
   
   var body: some View {
      Button(action: {
         self.isAnnotationSelected = true
         TapticEngine.impact.feedback(.light)
      }) {
         StopIcon(
            orderInRoute: self.connection.orderInRoute,
//            direction: self.connection.direction ?? .circular,
            direction: .circular,
            isSelected: self.isAnnotationSelected
         )
      }
      .frame(width: 40, height: 40, alignment: .center)
      .sheet(isPresented: $isAnnotationSelected, onDismiss: {
         withAnimation(.easeInOut(duration: 0.1)) {
            self.isAnnotationSelected = false
         }
      }) {
         ConnectionDetailsView(connection: self.connection)
      }
   }
   
}





struct CarrisVehicleAnnotationView: View {
   
   let vehicle: CarrisVehicle
   
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
                  Image("RegularService-Active")
            }
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .rotationEffect(.radians(vehicle.angleInRadians ?? 0))
      .sheet(isPresented: $isPresented) {
         VStack(alignment: .leading) {
            VehicleDetailsView(
               vehicle: self.vehicle,
               busNumber: vehicle.id,
               routeNumber: vehicle.routeNumber ?? "-",
               lastGpsTime: vehicle.lastGpsTime ?? ""
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
