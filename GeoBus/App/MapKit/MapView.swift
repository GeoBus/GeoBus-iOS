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

   @EnvironmentObject var routesController: RoutesController
   @EnvironmentObject var vehiclesController: VehiclesController

   @State var lisbonArea = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732),
      latitudinalMeters: 15000, longitudinalMeters: 15000
   )

   @State var stopAnnotations: [GenericMapAnnotation] = []
   @State var vehicleAnnotations: [GenericMapAnnotation] = []

   @State var visibleAnnotations: [GenericMapAnnotation] = []


   var body: some View {

      Map(
         coordinateRegion: $lisbonArea,
         showsUserLocation: true,
         annotationItems: visibleAnnotations
      ) { annotation in

         MapAnnotation(coordinate: annotation.location) {

            switch (annotation.format) {
               case .stop:
                  StopAnnotationView(stop: annotation.stop!)
                     .environmentObject(routesController)
                  
               case .vehicle:
                  VehicleAnnotationView(vehicle: annotation.vehicle!)
            }

         }

      }
      .onTapGesture {
         if (routesController.selectedRouteVariantStop != nil) {
            // Dismiss the stop selection when taping the map
            self.routesController.deselectStop()
         }
      }
      .onChange(of: routesController.selectedRouteVariant) { newVariant in

         stopAnnotations = []

         var tempStopAnnotations: [GenericMapAnnotation] = []

         if (newVariant != nil) {

            if (newVariant!.upItinerary != nil) {
               for stop in newVariant!.upItinerary! {
                  tempStopAnnotations.append(
                     GenericMapAnnotation(lat: stop.lat, lng: stop.lng, format: .stop, stop: stop)
                  )
               }
            }

            if (newVariant!.downItinerary != nil) {
               for stop in newVariant!.downItinerary! {
                  tempStopAnnotations.append(
                     GenericMapAnnotation(lat: stop.lat, lng: stop.lng, format: .stop, stop: stop)
                  )
               }
            }

            if (newVariant!.circItinerary != nil) {
               for stop in newVariant!.circItinerary! {
                  tempStopAnnotations.append(
                     GenericMapAnnotation(lat: stop.lat, lng: stop.lng, format: .stop, stop: stop)
                  )
               }
            }

            stopAnnotations = tempStopAnnotations

            visibleAnnotations = []
            visibleAnnotations.append(contentsOf: stopAnnotations)
            visibleAnnotations.append(contentsOf: vehicleAnnotations)

         }

      }
      .onChange(of: vehiclesController.vehicles) { newVehiclesList in

         vehicleAnnotations = []

         var tempVehicleAnnotations: [GenericMapAnnotation] = []

         for vehicle in newVehiclesList {
            tempVehicleAnnotations.append(
               GenericMapAnnotation(lat: vehicle.lat, lng: vehicle.lng, format: .vehicle, vehicle: vehicle)
            )
         }

         vehicleAnnotations = tempVehicleAnnotations

         visibleAnnotations = []
         visibleAnnotations.append(contentsOf: stopAnnotations)
         visibleAnnotations.append(contentsOf: vehicleAnnotations)

      }

   }
}

//
//            if (newVariant!.circItinerary != nil) {
//               for stop in newVariant!.circItinerary! {
//                  formattedAnnotations.append(
//                     RouteVariantStopAnnotation(stop: stop)
//                  )
//               }
//            }



//
//         visibleAnnotations.append(
//            GBMapAnnotation(
//               lat: 38.71726602960976,
//               lng: -9.140555811954005,
//               format: .stop,
//               display: AnyView(test)
//            )






//      // If the selected stop matches the ID of this stop,
//      // then change it's marker image to indicate selection.
//      if (selectedStopAnnotation?.id == stop.id) {
//         Image("GreenInfo")
//
//      } else {
//         // Wrap the marker image in a View to configure
//         // touch target size and action on tap in one place.
//         VStack {
//            switch (stop.originalStop.direction) {
//               case .ascending:
//                  Image("PinkArrowUp")
//               case .descending:
//                  Image("OrangeArrowDown")
//               case .circular:
//                  Image("BlueArrowRight")
//            }
//         }
//         .frame(width: 40, height: 40, alignment: .center)
//         .background(in: Rectangle())
//         .onTapGesture {
//            self.selectedStopAnnotation = stop
//            self.routesController.selectedRouteVariantStop = stop.originalStop
//            print("UUID: \(stop.id)")
//            print("PUBLIC: \(stop.originalStop.publicId)")
//         }
//      }


//      ----------------------


//      .onChange(of: routesController.selectedRouteVariant) { newVariant in
//
//         var formattedAnnotations: [RouteVariantStopAnnotation] = []
//
//               if (newVariant != nil) {
//
//                  if (newVariant!.upItinerary != nil) {
//                     for stop in newVariant!.upItinerary! {
//                        formattedAnnotations.append(
//                           RouteVariantStopAnnotation(stop: stop)
//                        )
//                     }
//                  }
//
//                  if (newVariant!.downItinerary != nil) {
//                     for stop in newVariant!.downItinerary! {
//                        formattedAnnotations.append(
//                           RouteVariantStopAnnotation(stop: stop)
//                        )
//                     }
//                  }
//
//                  if (newVariant!.circItinerary != nil) {
//                     for stop in newVariant!.circItinerary! {
//                        formattedAnnotations.append(
//                           RouteVariantStopAnnotation(stop: stop)
//                        )
//                     }
//                  }
//
//               }
//
//         self.stopAnnotations = formattedAnnotations
//
//      }




//
//// If the selected stop matches the ID of this stop,
//// then change it's marker image to indicate selection.
//if (selectedStopAnnotation?.id == stop.id) {
//   Image("GreenInfo")
//
//} else {
//   // Wrap the marker image in a View to configure
//   // touch target size and action on tap in one place.
//   VStack {
//      switch (stop.originalStop.direction) {
//         case .ascending:
//            Image("PinkArrowUp")
//         case .descending:
//            Image("OrangeArrowDown")
//         case .circular:
//            Image("BlueArrowRight")
//      }
//   }
//   .frame(width: 40, height: 40, alignment: .center)
//   .background(in: Rectangle())
//   .onTapGesture {
//      self.selectedStopAnnotation = stop
//      self.routesController.selectedRouteVariantStop = stop.originalStop
//      print("UUID: \(stop.id)")
//      print("PUBLIC: \(stop.originalStop.publicId)")
//   }
//   }
