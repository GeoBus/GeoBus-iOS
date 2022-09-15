//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @StateObject var mapController: MapController = MapController()


   var theMap: some View {
      VStack {
         Map(
            coordinateRegion: $mapController.region,
            interactionModes: [.all],
            showsUserLocation: true,
            annotationItems: mapController.visibleAnnotations
         ) { annotation in

            MapAnnotation(coordinate: annotation.location) {
               switch (annotation.format) {
                  case .stop:
                     StopAnnotationView(stop: annotation.stop!)
                  case .vehicle:
                     VehicleAnnotationView(vehicle: annotation.vehicle!)
               }
            }

         }
      }
      .onChange(of: routesController.selectedVariant) { newVariant in
         if (newVariant != nil) {
            mapController.updateStopAnnotations(for: newVariant!)
         }
      }
      .onChange(of: vehiclesController.vehicles) { newVehiclesList in
         mapController.updateVehicleAnnotations(for: newVehiclesList)
      }
   }


   var centerMapOnUserLocationButton: some View {
      VStack {
         Image(systemName: "location.fill")
            .foregroundColor(Color(.systemBlue))
            .padding()
            .background(colorScheme == .dark ? Color(.systemGray5) : Color(.white))
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding()
      }
   }


   var userLocation: some View {
      VStack {
         Spacer()
         centerMapOnUserLocationButton
            .onTapGesture() {
               TapticEngine.impact.feedback(.medium)
               self.mapController.centerMapOnUserLocation(andZoom: false)
            }
            .onLongPressGesture() {
               TapticEngine.impact.feedback(.medium)
               TapticEngine.impact.feedback(.medium, withDelay: 0.2)
               TapticEngine.impact.feedback(.medium, withDelay: 0.4)
               self.mapController.centerMapOnUserLocation(andZoom: true)
            }
            .alert(isPresented: $mapController.showLocationNotAllowedAlert, content: {
               Alert(
                  title: Text("Allow Location Access"),
                  message: Text("You have to allow location access so that GeoBus can show where you are on the map."),
                  primaryButton: .cancel(),
                  secondaryButton: .default(Text("Allow in Settings")) {
                     UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                  }
               )
            })
      }
   }


   var body: some View {
      ZStack(alignment: .trailing) {
         theMap
         VStack(alignment: .trailing) {
            Spacer()
            userLocation
         }
      }
   }


}


extension MapView {

   @MainActor class MapController: ObservableObject {

      @Published var region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732),
         latitudinalMeters: 15000, longitudinalMeters: 15000
      )

      @Published var locationManager = CLLocationManager()
      @Published var showLocationNotAllowedAlert: Bool = false

      @Published var visibleAnnotations: [GenericMapAnnotation] = []
      private var stopAnnotations: [GenericMapAnnotation] = []
      private var vehicleAnnotations: [GenericMapAnnotation] = []

      private var hasAlreadyInitiatedLocationManager: Bool = false



      func moveMap(to newRegion: MKCoordinateRegion) {
         DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.5)) {
               self.region = newRegion
            }
         }
      }


      func centerMapOnUserLocation(andZoom: Bool) {

         if (!hasAlreadyInitiatedLocationManager) {
            locationManager.requestWhenInUseAuthorization()
            hasAlreadyInitiatedLocationManager = true
         }

         if (locationManager.authorizationStatus == .authorizedWhenInUse) {
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
            self.showLocationNotAllowedAlert = true
         }

      }



      func updateStopAnnotations(for selectedVariant: Variant) {

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
         visibleAnnotations.append(contentsOf: vehicleAnnotations)

         zoomToFitMapAnnotations(annotations: visibleAnnotations)

      }


      func updateVehicleAnnotations(for vehiclesList: [VehicleSummary]) {

         vehicleAnnotations = []

         for vehicle in vehiclesList {
            vehicleAnnotations.append(
               GenericMapAnnotation(lat: vehicle.lat, lng: vehicle.lng, format: .vehicle, vehicle: vehicle)
            )
         }

         visibleAnnotations = []
         visibleAnnotations.append(contentsOf: stopAnnotations)
         visibleAnnotations.append(contentsOf: vehicleAnnotations)

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

}
