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
      //      case ministop(CarrisNetworkModel.Stop)
   }
   
}



struct CarrisConnectionAnnotationView: View {
   
   public let connection: CarrisNetworkModel.Connection
   
   @ObservedObject private var sheetController = SheetController.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body2: some View {
      EmptyView()
   }
   
   var body: some View {
      Button(action: {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(connection: self.connection)
         sheetController.present(sheet: .ConnectionDetails)
      }) {
         if (carrisNetworkController.activeConnection?.id == self.connection.id) {
            StopIcon(style: .selected, orderInRoute: self.connection.orderInRoute)
         } else if (self.connection.direction == .ascending) {
            StopIcon(style: .ascending, orderInRoute: self.connection.orderInRoute)
         } else if (self.connection.direction == .descending) {
            StopIcon(style: .descending, orderInRoute: self.connection.orderInRoute)
         } else if (self.connection.direction == .circular) {
            StopIcon(style: .circular, orderInRoute: self.connection.orderInRoute)
         } else {
            StopIcon(style: .standard)
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
   }
   
}





struct CarrisVehicleAnnotationView: View {
   
   let vehicle: CarrisNetworkModel.Vehicle
   
   @ObservedObject private var sheetController = SheetController.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body2: some View {
      EmptyView()
   }
   
   
   var body: some View {
      Button(action: {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(vehicle: vehicle.id)
         sheetController.present(sheet: .VehicleDetails)
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





struct StopAnnotationView: View {
   
   public let stop: CarrisNetworkModel.Stop
   
   @StateObject private var sheetController = SheetController.shared
   @StateObject private var mapController = MapController.shared
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      VStack {
         if (carrisNetworkController.activeStop?.id == self.stop.id) {
            StopIcon(style: .selected)
         } else if (mapController.region.span.latitudeDelta < 0.0025 || mapController.region.span.longitudeDelta < 0.0025) {
            StopIcon(style: .standard)
         } else {
            StopIcon(style: .mini)
         }
      }
      .onTapGesture {
         TapticEngine.impact.feedback(.light)
         carrisNetworkController.select(stop: self.stop)
         sheetController.present(sheet: .StopDetails)
         // withAnimation(.easeIn(duration: 0.5)) {
         //    mapController.centerMapOnCoordinates(lat: self.stop.lat, lng: self.stop.lng)
         // }
      }
   }
   
}
