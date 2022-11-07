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
      case ministop(CarrisNetworkModel.Stop)
   }
   
}





struct CarrisStopAnnotationView: View {
   
   public let stop: CarrisNetworkModel.Stop
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body: some View {
      Button(action: {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(stop: self.stop)
         appstate.present(sheet: .carris_stopDetails)
      }) {
         StopIcon(isSelected: carrisNetworkController.activeStop?.id == self.stop.id)
      }
      .frame(width: 40, height: 40, alignment: .center)
   }
   
}


struct CarrisConnectionAnnotationView: View {
   
   public let connection: CarrisNetworkModel.Connection
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body2: some View {
      EmptyView()
   }
   
   var body: some View {
      Button(action: {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(connection: self.connection)
         appstate.present(sheet: .carris_connectionDetails)
      }) {
         StopIcon(
            orderInRoute: self.connection.orderInRoute,
            direction: self.connection.direction,
            isSelected: carrisNetworkController.activeConnection == self.connection
         )
      }
      .frame(width: 40, height: 40, alignment: .center)
   }
   
}





struct CarrisVehicleAnnotationView: View {
   
   let vehicle: CarrisNetworkModel.Vehicle
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body2: some View {
      EmptyView()
   }
   
   
   var body: some View {
      Button(action: {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(vehicle: vehicle.id)
         appstate.present(sheet: .carris_vehicleDetails)
      }) {
         ZStack(alignment: .init(horizontal: .leading, vertical: .center)) {
            switch (vehicle.kind) {
               case .tram, .elevator:
                  Image("Tram")
               case .neighborhood, .night, .regular, .none:
                  Image("RegularService")
            }
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .rotationEffect(.radians(vehicle.angleInRadians ?? 0))
      .animation(.default, value: vehicle.angleInRadians)
   }
   
}





struct CarrisMiniStopAnnotationView: View {
   
   public let stop: CarrisNetworkModel.Stop
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var mapController = MapController.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var icon: some View {
      Button(action: {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(stop: self.stop)
         appstate.present(sheet: .carris_stopDetails)
      }) {
         Circle()
            .foregroundColor(.blue)
            .background(Color(.blue))
      }
      .frame(width: 15, height: 15, alignment: .center)
   }
   
   
   var body: some View {
      if (mapController.region.span.latitudeDelta < 0.0025 || mapController.region.span.longitudeDelta < 0.0025) {
         icon
      } else {
         Circle()
            .foregroundColor(.blue)
            .background(Color(.blue))
            .frame(width: 5, height: 5)
      }
   }
   
}
