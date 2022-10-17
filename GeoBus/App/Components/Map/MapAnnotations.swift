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
      case carris_stop(Stop_NEW)
      case carris_connection(Connection_NEW)
      case carris_vehicle(CarrisVehicle)
   }
   
}





struct CarrisStopAnnotationView: View {
   
   public let stop: Stop_NEW
   
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
   
   public let connection: Connection_NEW
   
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
   
   @ObservedObject var vehicle: CarrisVehicle
   
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
