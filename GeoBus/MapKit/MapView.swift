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
    mapView.isPitchEnabled = false
    
    mapView.register(StopAnnotationView.self, forAnnotationViewWithReuseIdentifier: "stop")
    mapView.register(VehicleAnnotationView.self, forAnnotationViewWithReuseIdentifier: "vehicle")
    
    // Set initial location in Lisbon
    let lisbon = CLLocation(latitude: 38.721917, longitude: -9.137732)
    let lisbonArea = MKCoordinateRegion(center: lisbon.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
    mapView.setRegion(lisbonArea, animated: true)
    
    // Only ask for location the second time the user opens the app
    if UserManagement().isReturningUser() { locationManager.requestWhenInUseAuthorization() }
    else { UserManagement().setReturningUser() }
    
    return mapView
  }
  
  
  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    
    var annotationsToAdd: [MKAnnotation] = []
    var annotationsToRemove: [MKAnnotation] = []
    
    let routeChanged = routesStorage.routeChanged
    
    // Only update stopAnnotations if variant has changed
    if routeChanged {
      routesStorage.routeChanged = false
      annotationsToAdd.append(contentsOf: routesStorage.stopAnnotations)
      for annotation in mapView.annotations {
        if annotation.isKind(of: StopAnnotation.self) {
          annotationsToRemove.append(annotation)
        }
      }
    }
    
    // Always update vehicleAnnotations
    annotationsToAdd.append(contentsOf: vehiclesStorage.annotations)
    for annotation in mapView.annotations {
      if annotation.isKind(of: VehicleAnnotation.self) {
        annotationsToRemove.append(annotation)
      }
    }
    
    // Update whatever was set to update
    mapView.removeAnnotations(annotationsToRemove)
    mapView.addAnnotations(annotationsToAdd)
    
    if routeChanged { mapView.showAnnotations(annotationsToAdd, animated: true) }
    
  }
  
  
  func makeCoordinator() -> MapView.Coordinator {
    Coordinator(control: self)
  }
  
  
  
  // MARK: - MKMapViewDelegate
  
  final class Coordinator: NSObject, MKMapViewDelegate {
    
    private let control: MapView
    
    init(control: MapView) {
      self.control = control
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      if view.isKind(of: StopAnnotationView.self) {
        
        let selectedStopAnnotationView = view as! StopAnnotationView
        let stopAnnotation = selectedStopAnnotationView.annotation as! StopAnnotation
        
        selectedStopAnnotationView.marker.image = UIImage(named: "GreenInfo")
        
        control.routesStorage.select(stop: stopAnnotation)
        
      } else if view.isKind(of: VehicleAnnotationView.self) {
        
        print()
        
      }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      if view.isKind(of: StopAnnotationView.self) {
        
        let selectedStopAnnotationView = view as! StopAnnotationView
        let stopAnnotation = selectedStopAnnotationView.annotation as! StopAnnotation
        
        selectedStopAnnotationView.marker.image = stopAnnotation.markerSymbol
        
        control.routesStorage.select(stop: nil)
        
      }
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
