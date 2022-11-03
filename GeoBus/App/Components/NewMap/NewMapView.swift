//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//



import SwiftUI
import MapKit

struct NewMapView: UIViewRepresentable {
   
   private let mapView = MKMapView()
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   func makeUIView(context: UIViewRepresentableContext<NewMapView>) -> MKMapView {
      
      mapView.delegate = context.coordinator
      mapView.mapType = MKMapType.standard
      mapView.showsUserLocation = true
      mapView.showsTraffic = true
      mapView.isRotateEnabled = false
      mapView.isPitchEnabled = false
      
      mapView.register(NewConnectionAnnotationView.self, forAnnotationViewWithReuseIdentifier: "stop")
      
      // Set initial location in Lisbon
      let lisbon = CLLocation(latitude: 38.721917, longitude: -9.137732)
      let lisbonArea = MKCoordinateRegion(center: lisbon.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
      mapView.setRegion(lisbonArea, animated: true)
      
      return mapView
   }
   
   
   func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<NewMapView>) {
      
      var annotationsToAdd: [MKAnnotation] = []
      
      print("MAPTEST: is called updateUIView")
//      print("MAPTEST: carrisNetworkController.activeRoute: \(carrisNetworkController.activeRoute)")
      
      if (carrisNetworkController.activeRoute != nil) {
         for connection in carrisNetworkController.activeRoute?.variants[0].ascendingItinerary ?? [] {
            annotationsToAdd.append(
               NewConnectionAnnotation(
                  name: connection.stop.name,
                  publicId: connection.stop.id,
                  latitude: connection.stop.lat,
                  longitude: connection.stop.lng,
                  connection: connection
               )
            )
         }
      }
      
      
      // Update whatever was set to update
//      mapView.removeAnnotations([])
      uiView.addAnnotations(annotationsToAdd)
      
      uiView.showAnnotations(annotationsToAdd, animated: true)
      
   }
   
   
   func makeCoordinator() -> NewMapView.Coordinator {
      Coordinator(control: self)
   }
   
   
   
   // MARK: - MKMapViewDelegate
   
   final class Coordinator: NSObject, MKMapViewDelegate {
      
      private let control: NewMapView
      
      private let appstate = Appstate.shared
      private let carrisNetworkController = CarrisNetworkController.shared
      
      init(control: NewMapView) {
         self.control = control
      }
      
      
      
      @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         print("MAPTEST: mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)")
         if view.isKind(of: NewConnectionAnnotationView.self) {

            let selectedStopAnnotationView = view as! NewConnectionAnnotationView
            let stopAnnotation = selectedStopAnnotationView.annotation as! NewConnectionAnnotation

//            selectedStopAnnotationView.marker.image = UIImage(named: "GreenInfo")

            TapticEngine.impact.feedback(.light)
            _ = carrisNetworkController.select(connection: stopAnnotation.connection)
            appstate.present(sheet: .carris_connectionDetails)

         }
      }
      
      
      
      @MainActor func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
         print("MAPTEST: mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)")
         if view.isKind(of: NewConnectionAnnotationView.self) {
            
//            let selectedStopAnnotationView = view as! NewConnectionAnnotationView
//            let stopAnnotation = selectedStopAnnotationView.annotation as! NewConnectionAnnotation
            
//            selectedStopAnnotationView.marker.image = stopAnnotation.markerSymbol
            
            carrisNetworkController.deselect([.connection])
            
         }
      }
      
      
      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         print("MAPTEST: mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?")
         if annotation.isKind(of: NewConnectionAnnotation.self) {
            
//            return MKAnnotationView(annotation: annotation, reuseIdentifier: "stop")
            
            let identifier = "stop"
            var view: MKAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
               dequeuedView.annotation = annotation
               view = dequeuedView
            } else {
               view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            return view
            
         } else {
            
            return nil
            
         }
         
      }
      
      
   }
   
}











class NewConnectionAnnotationView: MKAnnotationView {
   
   override var annotation: MKAnnotation? {

      willSet {
         guard let annotation = newValue as? NewConnectionAnnotation else {
            return
         }

         canShowCallout = false

//         marker.image = annotation.markerSymbol
//         marker.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
//         frame = marker.frame
         let swiftUIView = CarrisConnectionAnnotationView(connection: annotation.connection) // swiftUIView is View
         let viewCtrl = UIHostingController(rootView: swiftUIView)
         addSubview(viewCtrl.view)

      }

   }
   
   
   
}



class NewConnectionAnnotation: NSObject, MKAnnotation {
   
   let name: String
   let publicId: Int
   
   let coordinate: CLLocationCoordinate2D
   
   let connection: CarrisNetworkModel.Connection
   
   
   init(name: String?, publicId: Int?, latitude: Double, longitude: Double, connection: CarrisNetworkModel.Connection) {
      self.name = name ?? "-"
      self.publicId = publicId ?? -1
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.connection = connection
      super.init()
   }
   
   
//   var title: String? = nil
//
//   var subtitle: String? = nil
   
   
   var markerSymbol = UIImage(named: "PinkArrowUp")
   
}

