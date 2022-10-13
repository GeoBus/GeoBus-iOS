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
   @Published var visibleAnnotations: [GenericMapAnnotation] = []
   
   
   
   /* MARK: - RECEIVE APPSTATE & AUTHENTICATION */
   
   var appstate = Appstate()
   var analytics = Analytics()
   
   func receive(_ appstate: Appstate, _ analytics: Analytics) {
      self.appstate = appstate
      self.analytics = analytics
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
         self.analytics.capture(event: .Location_Status_Allowed)
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
         self.analytics.capture(event: .Location_Status_Denied)
         self.showLocationNotAllowedAlert = true
      }
      
   }
   
   
   
   /* MARK: - UPDATE ANNOTATIONS WITH SELECTED STOP */
   
   // .....
   
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
   
   
   
   /* MARK: - UPDATE ANNOTATIONS WITH SELECTED VARIANT */
   
   // .....
   
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
   
   
   
   /* MARK: - UPDATE ANNOTATIONS WITH VEHICLES LIST */
   
   // .....
   
   func updateAnnotations(with vehiclesList: [Vehicle], for routeNumber: String?) {
      
      if (routeNumber != nil) {
         
         // Filter Vehicles matching the required conditions:
         for vehicle in vehiclesList {
            
            // CONDITION 1:
            // Vehicle is currently driving the requested routeNumber
            let matchesSelectedRouteNumber = vehicle.routeNumber == routeNumber
            
            // CONDITION 2:
            // Vehicle was last seen no longer than 3 minutes
            let isNotZombieVehicle = Globals().getLastSeenTime(since: vehicle.lastGpsTime ?? "") < 180
            
            
            // Find index of Annotation matching this vehicle busNumber
            let indexOfVisibleAnnotation = visibleAnnotations.firstIndex(where: {
               return $0.format == .vehicle && $0.busNumber == vehicle.busNumber
            })
            
            // Only proceed if ALL conditions are true
            if (matchesSelectedRouteNumber && isNotZombieVehicle) {
               if (indexOfVisibleAnnotation != nil) {
                  // If annotation already exists, update it's values
                  withAnimation(.easeIn(duration: 0.5)) {
                     self.visibleAnnotations[indexOfVisibleAnnotation!].location.latitude = vehicle.lat ?? 0
                     self.visibleAnnotations[indexOfVisibleAnnotation!].location.longitude = vehicle.lng ?? 0
                     self.visibleAnnotations[indexOfVisibleAnnotation!].vehicle = vehicle
                  }
               } else {
                  // If annotation does not already exist, create a new one
                  visibleAnnotations.append(
                     GenericMapAnnotation(
                        lat: vehicle.lat ?? 0,
                        lng: vehicle.lng ?? 0,
                        format: .vehicle,
                        busNumber: vehicle.busNumber,
                        vehicle: vehicle
                     )
                  )
               }
            } else {
               if (indexOfVisibleAnnotation != nil) {
                  // If annotation exists but does not pass conditions, remove it
                  visibleAnnotations.remove(at: indexOfVisibleAnnotation!)
               }
            }
         }
         
      } else {
         // Remove all if no route is selected
         visibleAnnotations.removeAll()
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
