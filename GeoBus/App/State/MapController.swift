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
   
   
   
   func moveMap(to newRegion: MKCoordinateRegion) {
      withAnimation(.easeIn(duration: 0.5)) {
         self.region = newRegion
      }
   }
   
   
   func centerMapOnUserLocation(andZoom: Bool) {
      
      locationManager.requestWhenInUseAuthorization()
      
      if (locationManager.authorizationStatus == .authorizedWhenInUse) {
         self.appstate.capture(event: "Location-Status-Allowed")
         if (andZoom) {
            self.moveMap(to: MKCoordinateRegion(
               center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
               latitudinalMeters: 350, longitudinalMeters: 350
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
//      visibleAnnotations.append(contentsOf: vehicleAnnotations)
      
      zoomToFitMapAnnotations(annotations: visibleAnnotations)
      
   }
   
   
   
   func updateAnnotations(with vehiclesList: [VehicleSummary]) {
      
      //      vehicleAnnotations = []
      
      for vehicle in vehiclesList {
         let indexOfVehicleAnnotation = visibleAnnotations.firstIndex {
            $0.id == vehicle.busNumber
         }
         
         print("GB: Index is \(String(describing: indexOfVehicleAnnotation))")
         
         if (indexOfVehicleAnnotation != nil) {
            self.visibleAnnotations[indexOfVehicleAnnotation!].location = CLLocationCoordinate2D(
               latitude: vehicle.lat, longitude: vehicle.lng
            )
         } else {
            visibleAnnotations.append(GenericMapAnnotation(lat: vehicle.lat, lng: vehicle.lng, format: .vehicle, vehicle: vehicle))
         }
      }
      
      //      for vehicle in vehiclesList {
      //         vehicleAnnotations.append(
      //            GenericMapAnnotation(lat: vehicle.lat, lng: vehicle.lng, format: .vehicle, vehicle: vehicle)
      //         )
      //      }
      
      //      visibleAnnotations.removeAll()
      //      visibleAnnotations.append(contentsOf: stopAnnotations)
      //      visibleAnnotations.append(contentsOf: vehicleAnnotations)
      
   }
   
   
   
   func zoomToFitMapAnnotations(annotations: [GenericMapAnnotation]) {
      guard annotations.count > 0 else {
         return
      }
      var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
      topLeftCoord.latitude = -90
      topLeftCoord.longitude = 180
      var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
      bottomRightCoord.latitude = 90
      bottomRightCoord.longitude = -180
      for annotation in annotations {
         topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.location.longitude)
         topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.location.latitude)
         bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.location.longitude)
         bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.location.latitude)
      }
      
      var newRegion: MKCoordinateRegion = MKCoordinateRegion()
      newRegion.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
      newRegion.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
      newRegion.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
      newRegion.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
      
      self.moveMap(to: newRegion)
      
   }
   
}
