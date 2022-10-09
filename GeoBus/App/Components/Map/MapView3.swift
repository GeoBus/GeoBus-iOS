////
////  MapView.swift
////  GeoBus
////
////  Created by João de Vasconcelos on 10/09/2022.
////  Copyright © 2022 João de Vasconcelos. All rights reserved.
////
//
//import SwiftUI
//import MapKit
//
//
//struct MapView: UIViewRepresentable {
//   @Binding var route: MKPolyline?
//   let mapViewDelegate = MapViewDelegate()
//
//   func makeUIView(context: Context) -> MKMapView {
//      MKMapView(frame: .zero)
//   }
//
//   func updateUIView(_ view: MKMapView, context: Context) {
//      view.delegate = mapViewDelegate                          // (1) This should be set in makeUIView, but it is getting reset to `nil`
//      view.translatesAutoresizingMaskIntoConstraints = false   // (2) In the absence of this, we get constraints error on rotation; and again, it seems one should do this in makeUIView, but has to be here
//      addRoute(to: view)
//   }
//}
//
//private extension MapView {
//   func addRoute(to view: MKMapView) {
//      if !view.overlays.isEmpty {
//         view.removeOverlays(view.overlays)
//      }
//
//      guard let route = route else { return }
//      let mapRect = route.boundingMapRect
//      view.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
//      view.addOverlay(route)
//   }
//}
//
//class MapViewDelegate: NSObject, MKMapViewDelegate {
//   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//      let renderer = MKPolylineRenderer(overlay: overlay)
//      renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
//      renderer.strokeColor = UIColor.red.withAlphaComponent(0.8)
//      return renderer
//   }
//}
