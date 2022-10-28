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
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   
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
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   
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
   
   @ObservedObject var appstate = Appstate.shared
   @ObservedObject var carrisNetworkController = CarrisNetworkController.shared
   
   
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
