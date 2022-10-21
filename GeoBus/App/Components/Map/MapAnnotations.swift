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

   let id: Int
   var location: CLLocationCoordinate2D
   var item: AnnotationItem
   
   enum AnnotationItem {
      case carris_stop(CarrisNetworkModel.Stop)
      case carris_connection(CarrisNetworkModel.Connection)
      case carris_vehicle(CarrisNetworkModel.Vehicle)
   }
   
}





struct CarrisStopAnnotationView: View {
   
   public let stop: CarrisNetworkModel.Stop
   
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
         StopDetailsView(stop: self.stop)
      }
   }
   
}


struct CarrisConnectionAnnotationView: View {
   
   public let connection: CarrisNetworkModel.Connection
   
   @State private var isAnnotationSelected: Bool = false
   
   
   var body: some View {
      Button(action: {
         self.isAnnotationSelected = true
         TapticEngine.impact.feedback(.light)
      }) {
         StopIcon(
            orderInRoute: self.connection.orderInRoute,
            direction: self.connection.direction,
            isSelected: self.isAnnotationSelected
         )
      }
      .frame(width: 40, height: 40, alignment: .center)
      .sheet(isPresented: $isAnnotationSelected, onDismiss: {
         self.isAnnotationSelected = false
      }) {
         ConnectionDetailsView(connection: self.connection)
      }
   }
   
}





struct CarrisVehicleAnnotationView: View {
   
   let vehicle: CarrisNetworkModel.Vehicle
   
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
      .animation(.default, value: vehicle.angleInRadians)
      .sheet(isPresented: $isPresented) {
         VStack(alignment: .leading) {
            VehicleDetailsView(vehicle: self.vehicle)
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
