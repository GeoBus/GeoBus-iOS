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
                                                         
  @ObservedObject var stopsStorage: StopsStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @State var mapView = MKMapView()
  private let locationManager = CLLocationManager()
  
  
  func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
    mapView.delegate = context.coordinator
    mapView.mapType = MKMapType.mutedStandard
    mapView.showsUserLocation = true
    mapView.showsTraffic = true
    
    locationManager.requestWhenInUseAuthorization()
    
    return mapView
  }
  
  
  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    
    var newAnnotations: [MKAnnotation] = []
    newAnnotations.append(contentsOf: stopsStorage.annotations)
    newAnnotations.append(contentsOf: vehiclesStorage.annotations)
    
    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotations(newAnnotations)
    
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
        
      } else if annotation.isKind(of: StopAnnotation.self) {
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "stopsAnnotationView")
        annotationView.image = StopAnnotationView().asImage()
        annotationView.canShowCallout = true
        
        return annotationView
        
      } else if annotation.isKind(of: VehicleAnnotation.self) {
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "vehiclesAnnotationView")
        annotationView.image = VehicleAnnotationView(title: annotation.title!!).asImage()
        annotationView.canShowCallout = true
        
        return annotationView
        
      } else {
        return nil
      }
    }
    
  }
}
