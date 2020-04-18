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
  @Binding var vehicleLocations: VehicleLocations


  func makeCoordinator() -> MapViewCoordinator {
    return MapViewCoordinator(mapView: self)
  }

  func makeUIView(context: Context) -> MKMapView {
    return mapView
  }

  func updateUIView(_ view: MKMapView, context: Context) {
    //If you changing the Map Annotation then you have to remove old Annotations
    view.delegate = context.coordinator
    view.showsUserLocation = true
  }

}
