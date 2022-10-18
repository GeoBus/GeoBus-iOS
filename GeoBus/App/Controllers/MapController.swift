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
   
   /* * */
   /* MARK: - SECTION 1: SETTINGS */
   /* Static settings for the Map view. */
   
   private let initialMapRegion = CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732)
   private let initialMapZoom = CLLocationDistance(15000)
   
   private let annotationsZoomMargin = 1.7 // The margin on the sides of the annotations
   
   
   
   /* * */
   /* MARK: - SECTION 2: PUBLISHED PROPERTIES */
   /* Here are all the @Published variables that can be consumed by the app views. */
   
   @Published var region = MKCoordinateRegion()
   
   @Published var locationManager = CLLocationManager()
   @Published var showLocationNotAllowedAlert: Bool = false
   
   @Published var visibleAnnotations: [GenericMapAnnotation] = []
   
   
   
   /* * */
   /* MARK: - SECTION 3: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   static let shared = MapController()
   
   
   
   /* * */
   /* MARK: - SECTION 4: INITIALIZER */
   /* Protect the initializer to ensure only one instance of this class is created. */
   /* Setup the initial map region on init. */
   
   private init() {
      self.region = MKCoordinateRegion(center: initialMapRegion, latitudinalMeters: initialMapZoom, longitudinalMeters: initialMapZoom)
   }
   
   
   
   /* * */
   /* MARK: - SECTION 5: MOVE MAP TO NEW COORDINATE REGION */
   /* Helper function to animate the Map changing region. */
   
   func moveMap(to newRegion: MKCoordinateRegion) {
      DispatchQueue.main.async {
         withAnimation(.easeIn(duration: 0.5)) {
            self.region = newRegion
         }
      }
   }
   
   
   
   /* * */
   /* MARK: - SECTION 6: CENTER MAP ON USER LOCATION */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
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
   
   
   
   /* * */
   /* MARK: - SECTION 7: ZOOM MAP TO FIT ANNOTATIONS */
   /* Given an array of annotations, calculate the 4 coordinates that encompass */
   /* all of them in the map, give them a little padding on all sides, and move the map. */
   
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
      
      var newRegion: MKCoordinateRegion = MKCoordinateRegion()
      newRegion.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
      newRegion.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
      newRegion.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * annotationsZoomMargin
      newRegion.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * annotationsZoomMargin
      
      self.moveMap(to: newRegion)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8: UPDATE ANNOTATIONS WITH SELECTED CARRIS STOP */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(with activeStop: CarrisNetworkModel.Stop) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .carris_stop(_), .carris_connection(_), .carris_vehicle(_):
               return true
         }
      })
      
      visibleAnnotations.append(
         GenericMapAnnotation(
            id: activeStop.id,
            location: CLLocationCoordinate2D(latitude: activeStop.lat, longitude: activeStop.lng),
            item: .carris_stop(activeStop)
         )
      )
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 9: UPDATE ANNOTATIONS WITH SELECTED CARRIS VARIANT */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(with activeVariant: CarrisNetworkModel.Variant) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .carris_connection(_), .carris_stop(_):
               return true
            case .carris_vehicle(_):
               return false
         }
      })
      
      if (activeVariant.circularItinerary != nil) {
         for connection in activeVariant.circularItinerary! {
            visibleAnnotations.append(
               GenericMapAnnotation(
                  id: connection.stop.id,
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      if (activeVariant.ascendingItinerary != nil) {
         for connection in activeVariant.ascendingItinerary! {
            visibleAnnotations.append(
               GenericMapAnnotation(
                  id: connection.stop.id,
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      if (activeVariant.descendingItinerary != nil) {
         for connection in activeVariant.descendingItinerary! {
            visibleAnnotations.append(
               GenericMapAnnotation(
                  id: connection.stop.id,
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      // Remove annotations with duplicate IDs (same stop on different itineraries)
      visibleAnnotations.uniqueInPlace(for: \.id)
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 10: UPDATE ANNOTATIONS WITH ACTIVE CARRIS VEHICLES */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(with activeVehiclesList: [CarrisNetworkModel.Vehicle]) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .carris_vehicle(_), .carris_stop(_):
               return true
            case .carris_connection(_):
               return false
         }
      })
      
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
   
   
}
