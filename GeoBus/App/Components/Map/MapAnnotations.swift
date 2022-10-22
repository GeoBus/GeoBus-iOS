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
   
   let id: UUID
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
   
   @EnvironmentObject var appstate: Appstate
   @EnvironmentObject var carrisNetworkController: CarrisNetworkController
   
   @State private var isPresented: Bool = false
   @State private var viewSize = CGSize()
   
   
   var body: some View {
      Button(action: {
         carrisNetworkController.select(vehicle: vehicle.id)
         appstate.present(sheet: .carris_vehicleDetails)
         TapticEngine.impact.feedback(.light)
      }) {
         ZStack(alignment: .init(horizontal: .leading, vertical: .center)) {
            switch (vehicle.kind) {
               case .tram, .elevator:
                  Image("Tram")
               case .neighborhood, .night, .regular, .none:
                  Image("RegularService")
                  Text(verbatim: String(vehicle.id))
                     .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                     .tracking(1)
                     .foregroundColor(.white)
                     .padding(.leading, 12)
            }
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .rotationEffect(.radians(vehicle.angleInRadians ?? 0))
      .animation(.default, value: vehicle.angleInRadians)
   }
   
}
