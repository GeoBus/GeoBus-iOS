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
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage
  
  @State var mapView = MKMapView()
  
  private let locationManager = CLLocationManager()
  
  
  func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
    
    mapView.delegate = context.coordinator
    mapView.mapType = MKMapType.mutedStandard
    mapView.showsUserLocation = true
    mapView.showsTraffic = true
    mapView.isRotateEnabled = false
    
    mapView.register(StopAnnotationView.self, forAnnotationViewWithReuseIdentifier: "stop")
    mapView.register(VehicleAnnotationView.self, forAnnotationViewWithReuseIdentifier: "vehicle")
    
    // Set initial location in Lisbon
    let lisbon = CLLocation(latitude: 38.721917, longitude: -9.137732)
    let lisbonArea = MKCoordinateRegion(center: lisbon.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
    mapView.setRegion(lisbonArea, animated: true)
    
    if UserManagement().isReturningUser() {
      // Only ask for location the second time the user opens the app
      locationManager.requestWhenInUseAuthorization()
    } else {
      UserManagement().setReturningUser()
    }
    
    return mapView
  }
  
  
  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    
    var newAnnotations: [MKAnnotation] = []
    newAnnotations.append(contentsOf: routesStorage.stopAnnotations)
    newAnnotations.append(contentsOf: vehiclesStorage.annotations)

    mapView.removeAnnotations(mapView.annotations)
    mapView.addAnnotations(newAnnotations)
    
  }
  
  
  func makeCoordinator() -> MapView.Coordinator {
    Coordinator(self)
  }
  
  
  
  // MARK: - MKMapViewDelegate
  
  final class Coordinator: NSObject, MKMapViewDelegate {
    
    private let control: MapView
    
    
    init(_ control: MapView) {
      self.control = control
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      
      if annotation.isKind(of: StopAnnotation.self) {
        
        let identifier = "stop"
        var view: MKAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
          dequeuedView.annotation = annotation
          view = dequeuedView
        } else {
          view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        return view
        
      } else if annotation.isKind(of: VehicleAnnotation.self) {
        
        let identifier = "vehicle"
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
