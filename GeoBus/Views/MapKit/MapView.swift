//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//



import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
  
  @Binding var mapView: MKMapView
  @Binding var vehicleAnnotations: [MapAnnotation]
  
  
  func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
    mapView.delegate = context.coordinator
    mapView.mapType = MKMapType.mutedStandard
    mapView.showsUserLocation = true
    mapView.showsTraffic = true
    return mapView
  }
  
  
  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    mapView.addAnnotations(vehicleAnnotations)
  }
  
  
  func makeCoordinator() -> MapView.Coordinator {
    Coordinator(self)
  }
  
  
  
  // MARK: - MKMapViewDelegate
  
  final class Coordinator: NSObject, MKMapViewDelegate {
    
    var control: MapView
    
    init(_ control: MapView) {
      self.control = control
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

      if annotation.isKind(of: MKUserLocation.self) {
        return nil
      } else {

        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
        annotationView.image = VehicleAnnotationView(title: annotation.title!!).asImage()
        annotationView.canShowCallout = true

        return annotationView
      }
    }
    
//    private func mapView(_ mapView: MKMapView, viewFor annotation: MapAnnotation) -> MKAnnotationView? {
//
//      if annotation.isKind(of: MKUserLocation.self) {
//        return nil
//      } else {
//
//        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
//        annotationView.image = VehicleAnnotationView(title: (annotation.title ?? "-") ).asImage()
//        annotationView.canShowCallout = true
//
//        return annotationView
//      }
//    }
    
  }
}
