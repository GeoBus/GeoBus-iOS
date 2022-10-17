//
//  MapController.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/09/2022.
//

import Foundation
import MapKit
import SwiftUI

@MainActor
class MapController: ObservableObject {
   
   @Published var region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732),
      latitudinalMeters: 15000, longitudinalMeters: 15000
   )
   
   @Published var locationManager = CLLocationManager()
   @Published var showLocationNotAllowedAlert: Bool = false
   
   private var stopAnnotations: [GenericMapAnnotation] = []
   private var connectionAnnotations: [GenericMapAnnotation] = []
   @Published var visibleAnnotations: [GenericMapAnnotation] = []
   
   
   
   /* MARK: - MOVE MAP TO NEW COORDINATE REGION */
   
   // Helper function to animate Map changing region.
   
   func moveMap(to newRegion: MKCoordinateRegion) {
      DispatchQueue.main.async {
         withAnimation(.easeIn(duration: 0.5)) {
            self.region = newRegion
         }
      }
   }
   
   
   
   /* MARK: - CENTER MAP ON USER LOCATION */
   
   // .....
   
   func centerMapOnUserLocation(andZoom: Bool) {
      
      locationManager.requestWhenInUseAuthorization()
      
      if (locationManager.authorizationStatus == .authorizedWhenInUse) {
         Analytics.shared.capture(event: .Location_Status_Allowed)
         if (andZoom) {
            self.moveMap(to: MKCoordinateRegion(
               center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
               latitudinalMeters: 400, longitudinalMeters: 400
            ))
         } else {
            self.moveMap(to: MKCoordinateRegion(
               center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
               span: region.span
            ))
         }
      } else if (locationManager.authorizationStatus != .notDetermined) {
         Analytics.shared.capture(event: .Location_Status_Denied)
         self.showLocationNotAllowedAlert = true
      }
      
   }
   
   
   
   /* MARK: - UPDATE ANNOTATIONS WITH SELECTED STOP */
   
   // .....
   
   func updateAnnotations(with selectedStop: CarrisNetworkModel.Stop) {
      
      visibleAnnotations.removeAll()
      
      visibleAnnotations.append(
         GenericMapAnnotation(
            id: Int(selectedStop.publicId) ?? 0,
            location: CLLocationCoordinate2D(latitude: selectedStop.lat, longitude: selectedStop.lng),
            item: .carris_stop(selectedStop)
         )
      )
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   /* MARK: - UPDATE ANNOTATIONS WITH SELECTED VARIANT */
   
   // .....
   
   func updateAnnotations(with selectedVariant: CarrisNetworkModel.Variant) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .carris_connection(_):
               return true
            case .carris_stop(_), .carris_vehicle(_):
               return false
         }
      })
      
      for itinerary in selectedVariant.itineraries {
         for connection in itinerary.connections {
            visibleAnnotations.append(
               GenericMapAnnotation(
                  id: Int(connection.stop.publicId) ?? 0,
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   /* MARK: - UPDATE ANNOTATIONS WITH VEHICLES LIST */
   
   // .....
   
   func updateAnnotations(with activeVehiclesList: [CarrisNetworkModel.Vehicle]) {
      
      visibleAnnotations.removeAll()
      
      for vehicle in activeVehiclesList {
         visibleAnnotations.append(
            GenericMapAnnotation(
               id: vehicle.id,
               location: vehicle.coordinate,
               item: .carris_vehicle(vehicle)
            )
         )
      }
      
   }
   
   
   
   /* MARK: - ZOOM MAP TO FIT ANNOTATIONS */
   
   // ......
   
   func zoomToFitMapAnnotations(annotations: [GenericMapAnnotation]) {
      guard annotations.count > 0 else {
         return
      }
      
      var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
      
      for annotation in annotations {
         topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.location.longitude)
         topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.location.latitude)
         bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.location.longitude)
         bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.location.latitude)
      }
      
      // The margin on the sides of the annotations
      let spanMargin = 1.7
      
      var newRegion: MKCoordinateRegion = MKCoordinateRegion()
      newRegion.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
      newRegion.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
      newRegion.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * spanMargin
      newRegion.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * spanMargin
      
      self.moveMap(to: newRegion)
      
   }
   
}
