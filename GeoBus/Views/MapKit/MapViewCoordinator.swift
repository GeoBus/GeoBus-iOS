//
//  MapViewCoordinator.swift
//  SwiftUI-MapView
//
//  Created by Anand Nimje on 12/12/19.
//  Copyright © 2019 Anand. All rights reserved.
//

import Foundation
import MapKit

/*
 Coordinator for using UIKit inside SwiftUI.
 */
class MapViewCoordinator: NSObject, MKMapViewDelegate {
  
  var mapView: MapView
  
  init(mapView: MapView) {
    self.mapView = mapView
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    mapView.showsUserLocation = true
    
    let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customView")
    
    let customView = CustomMKAnnotationView(annotation: annotationView.annotation! as! VehicleMapAnnotation)
    annotationView.image = customView.asImage()
    
    annotationView.canShowCallout = true
    
    return annotationView
  }
}
