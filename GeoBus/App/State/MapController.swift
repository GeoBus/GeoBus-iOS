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
   private var vehicleAnnotations: [GenericMapAnnotation] = []
   @Published var visibleAnnotations: [GenericMapAnnotation] = []
   
   
   
   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */
   
   var appstate = Appstate()
   
   func receive(state: Appstate) {
      self.appstate = state
   }
   
   
   
   /* MARK: - MOVE MAP TO NEW COORDINATE REGION */
   
   // Helper function to animate Map changing region.
   
   func moveMap(to newRegion: MKCoordinateRegion) {
      withAnimation(.easeIn(duration: 0.5)) {
         self.region = newRegion
      }
   }
   
   
   
   /* MARK: - CENTER MAP ON USER LOCATION */
   
   // .....
   
   func centerMapOnUserLocation(andZoom: Bool) {
      
      locationManager.requestWhenInUseAuthorization()
      
      if (locationManager.authorizationStatus == .authorizedWhenInUse) {
         self.appstate.capture(event: "Location-Status-Allowed")
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
         self.appstate.capture(event: "Location-Status-Denied")
         self.showLocationNotAllowedAlert = true
      }
      
   }
   
   
   
   func updateAnnotations(with selectedStop: Stop) {
      
      stopAnnotations = []
      
      stopAnnotations.append(
         GenericMapAnnotation(
            lat: selectedStop.lat,
            lng: selectedStop.lng,
            format: .singleStop,
            stop: selectedStop
         )
      )
      
      visibleAnnotations.removeAll()
      visibleAnnotations.append(contentsOf: stopAnnotations)
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   func updateAnnotations(with selectedVariant: Variant) {
      
      stopAnnotations = []
      
      if (selectedVariant.upItinerary != nil) {
         for stop in selectedVariant.upItinerary! {
            stopAnnotations.append(
               GenericMapAnnotation(lat: stop.lat, lng: stop.lng, format: .stop, stop: stop)
            )
         }
      }
      
      if (selectedVariant.downItinerary != nil) {
         for stop in selectedVariant.downItinerary! {
            stopAnnotations.append(
               GenericMapAnnotation(lat: stop.lat, lng: stop.lng, format: .stop, stop: stop)
            )
         }
      }
      
      if (selectedVariant.circItinerary != nil) {
         for stop in selectedVariant.circItinerary! {
            stopAnnotations.append(
               GenericMapAnnotation(lat: stop.lat, lng: stop.lng, format: .stop, stop: stop)
            )
         }
      }
      
      visibleAnnotations.removeAll()
      visibleAnnotations.append(contentsOf: stopAnnotations)
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   /* MARK: - UPDATE VEHICLE ANNOTATIONS */
   
   // On receiving a new list of Vehicles, loop through each one
   // to check if it is already present in the map. If it is, then update
   // it's the coordinates. If it is not, add it to the list of visible annotations.
   
   func updateAnnotations(with vehiclesList: [VehicleSummary]) {
      
      // Loop through the new list of vehicles
      for vehicle in vehiclesList {
         
         // Check if busNumber is already visible in the Map
         let indexOfVehicleAnnotation = visibleAnnotations.firstIndex {
            $0.id == vehicle.busNumber
         }
         
         if (indexOfVehicleAnnotation != nil) {
            // If it is, update it's coordinates
            self.visibleAnnotations[indexOfVehicleAnnotation!].location = CLLocationCoordinate2D(
               latitude: vehicle.lat, longitude: vehicle.lng
            )
         } else {
            // If it is not, add it to the map
            visibleAnnotations.append(GenericMapAnnotation(lat: vehicle.lat, lng: vehicle.lng, format: .vehicle, vehicle: vehicle))
         }
         
      }
      
      
      // MISSING: Remove vehicles in visibleAnnotations that are not in the list
      
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
