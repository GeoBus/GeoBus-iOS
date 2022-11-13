//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//



import SwiftUI
import MapKit

struct MapViewSwiftUI: UIViewRepresentable {
   
   private let mapView = MKMapView()
   
   @Binding var region: MKCoordinateRegion
   @Binding var camera: MKMapCamera
   @Binding var annotations: [GeoBusMKAnnotation]
   @Binding var overlays: [MKPolyline]
   
   @StateObject var carrisNetworkController = CarrisNetworkController.shared
   
   
   func makeUIView(context: UIViewRepresentableContext<MapViewSwiftUI>) -> MKMapView {
      mapView.delegate = context.coordinator
      mapView.region = self.region
      mapView.showsUserLocation = true
      mapView.userTrackingMode = .follow
      mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .muted)
      
      mapView.register(StopMKAnnotationView.self, forAnnotationViewWithReuseIdentifier: StopMKAnnotationView.reuseIdentifier)
      mapView.register(VehicleMKAnnotationView.self, forAnnotationViewWithReuseIdentifier: VehicleMKAnnotationView.reuseIdentifier)
      
      return mapView
   }
   
   
   func updateUIView(_ uiView: MKMapView, context: Context) {
      
      var tempAnnotationsToAdd: [GeoBusMKAnnotation] = []
      var tempAnnotationsToRemove: [GeoBusMKAnnotation] = []
      
      let tempCurrentAnnotations: [GeoBusMKAnnotation] = uiView.annotations.compactMap({
         // Make sure we are dealing with annotation of type GeoBusMKAnnotation
         return $0 as? GeoBusMKAnnotation
      })
      
      // Find out which annotations should be added to the map
      for newAnnotation in annotations {
         // If this annotation is not yet on the view, add it
         let indexOfThisNewAnnotationInUiView = tempCurrentAnnotations.firstIndex(of: newAnnotation)
         if (indexOfThisNewAnnotationInUiView == nil) {
            tempAnnotationsToAdd.append(newAnnotation)
         }
      }
      
      // Find out the excess annotations that should be removed from the map
      for currentAnnotation in tempCurrentAnnotations {
         // If this visible annotation is not in [annotations], remove it
         let indexOfThisCurrentAnnotationInNextAnnotations = annotations.firstIndex(of: currentAnnotation)
         if (indexOfThisCurrentAnnotationInNextAnnotations == nil) {
            tempAnnotationsToRemove.append(currentAnnotation)
         }
      }
      
      
      // Update the view with annotations
      uiView.removeAnnotations(tempAnnotationsToRemove)
      uiView.addAnnotations(tempAnnotationsToAdd)
      
      
      
      // OVERLAYS
      
      var tempOverlaysToAdd: [MKPolyline] = []
      
      for overlay in overlays {
         tempOverlaysToAdd.append(overlay)
      }
      
      uiView.addOverlays(tempOverlaysToAdd)
      
      
      print("HOWMANY currentAnnotations: \(tempCurrentAnnotations.count)")
      print("HOWMANY tempAnnotationsToAdd: \(tempAnnotationsToAdd.count)")
      print("HOWMANY tempAnnotationsToRemove: \(tempAnnotationsToRemove.count)")
      print("HOWMANY uiView displayed annotations: \(uiView.annotations.count)")
      print("HOWMANY ----------")
   }
   
   
   func makeCoordinator() -> MapViewSwiftUICoordinator {
      MapViewSwiftUICoordinator(self)
   }
   
}



final class MapViewSwiftUICoordinator: NSObject, MKMapViewDelegate {
   
   var parentSwiftUIView: MapViewSwiftUI
   
   init(_ parentSwiftUIView: MapViewSwiftUI) {
      self.parentSwiftUIView = parentSwiftUIView
   }
   
   
   @MainActor func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      DispatchQueue.main.async { [self] in
         self.parentSwiftUIView.region = mapView.region
         self.parentSwiftUIView.camera = mapView.camera
      }
   }
   
   @MainActor func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
      DispatchQueue.main.async { [self] in
         // self.parentSwiftUIView.region = mapView.region
         self.parentSwiftUIView.camera = mapView.camera
      }
   }
   
   
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard let annotation = annotation as? GeoBusMKAnnotation else { return nil }
      
      switch annotation.type {
         case .stop:
            return StopMKAnnotationView(annotation: annotation, reuseIdentifier: StopMKAnnotationView.reuseIdentifier)
         case .vehicle:
            return VehicleMKAnnotationView(annotation: annotation, reuseIdentifier: VehicleMKAnnotationView.reuseIdentifier)
      }
      
   }
   
   
   @MainActor func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
      guard let annotation = annotation as? GeoBusMKAnnotation else { return }
      
      switch annotation.type {
         case .stop:
            DispatchQueue.main.async { [self] in
               TapticEngine.impact.feedback(.light)
               _ = parentSwiftUIView.carrisNetworkController.select(stop: annotation.id)
               SheetController.shared.present(sheet: .StopDetails)
            }
         case .vehicle:
            DispatchQueue.main.async { [self] in
               TapticEngine.impact.feedback(.light)
               _ = parentSwiftUIView.carrisNetworkController.select(vehicle: annotation.id)
               SheetController.shared.present(sheet: .VehicleDetails)
            }
      }
   }
   
   
   
   @MainActor func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      print("HETERERERERERE : \(overlay)")
      if let polyline = overlay as? MKPolyline {
         print("HETERERERERERE27e53672")
         var testlineRenderer = MKPolylineRenderer(polyline: polyline)
         testlineRenderer.strokeColor = .systemPink
         testlineRenderer.lineWidth = 2.0
         return testlineRenderer
      }
      fatalError("Something wrong...")
   }
   
   
}






final class GeoBusMKAnnotation: NSObject, MKAnnotation {
   
   let type: AnnotationType
   
   let id: Int
   dynamic var coordinate: CLLocationCoordinate2D
   
   enum AnnotationType {
      case stop
      case vehicle
   }
   
   init(type: AnnotationType, id: Int, coordinate: CLLocationCoordinate2D) {
      self.id = id
      self.coordinate = coordinate
      self.type = type
   }
   
   func update(coordinate newCoordinate: CLLocationCoordinate2D) {
      self.coordinate = newCoordinate
   }
   
   override func isEqual(_ object: Any?) -> Bool {
      if let annot = object as? GeoBusMKAnnotation{
         // Add your defintion of equality here. i.e what determines if two Annotations are equal.
         let equalId = annot.id == self.id
         let equalCoordinates = annot.coordinate == self.coordinate
         let equalType = annot.type == self.type
         return equalId && equalCoordinates && equalType
      } else {
         return false
      }
   }
   
}




final class GeoBusMKOverlay: NSObject, MKOverlay {
   
   let type: OverlayType
   
   let id: Int
   var coordinate: CLLocationCoordinate2D
   var boundingMapRect: MKMapRect
   
   enum OverlayType {
      case route
   }
   
   init(type: OverlayType, id: Int, coordinate: CLLocationCoordinate2D, boundingMapRect: MKMapRect) {
      self.type = type
      self.id = id
      self.coordinate = coordinate
      self.boundingMapRect = boundingMapRect
   }
   
   override func isEqual(_ object: Any?) -> Bool {
      if let annot = object as? GeoBusMKAnnotation{
         // Add your defintion of equality here. i.e what determines if two Annotations are equal.
         //         let equalCoordinates = annot.coordinate == self.coordinate
         //         let equalType = annot.type == self.type
         //         return equalCoordinates && equalType
         return annot.id == self.id
      } else {
         return false
      }
   }
   
}














// STOP ANNOTATIONS

final class StopMKAnnotationView: MKAnnotationView {
   
   static let reuseIdentifier = "stop"
   
   override var annotation: MKAnnotation? {
      willSet {
         guard let newValue = newValue as? GeoBusMKAnnotation else { return }
         
         canShowCallout = false
         
         zPriority = MKAnnotationViewZPriority(0)
         
         let swiftUIView = StopSwiftUIAnnotationView(stopId: newValue.id)
         let uiKitView = UIHostingController(rootView: swiftUIView)
         addSubview(uiKitView.view)
      }
   }
   
}


struct StopSwiftUIAnnotationView: View {
   
   public let stopId: Int
   
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   
   var body: some View {
      VStack {
         if (carrisNetworkController.activeStop?.id == self.stopId) {
            StopIcon(style: .selected)
         } else {
            StopIcon(style: .mini)
         }
      }
   }
   
}











// VEHICLE ANNOTATIONS


final class VehicleMKAnnotationView: MKAnnotationView {
   
   static let reuseIdentifier = "vehicle"
   
   override var annotation: MKAnnotation? {
      willSet {
         guard let newValue = newValue as? GeoBusMKAnnotation else { return }
         
         canShowCallout = false
         
         zPriority = MKAnnotationViewZPriority(1)
         
         let swiftUIView = VehicleSwiftUIAnnotationView(vehicleId: newValue.id)
         let uiKitView = UIHostingController(rootView: swiftUIView)
         addSubview(uiKitView.view)
      }
   }
   
}


struct VehicleSwiftUIAnnotationView: View {
   
   public let vehicleId: Int
   
   @StateObject private var mapController = MapController.shared
   @StateObject private var carrisNetworkController = CarrisNetworkController.shared
   
   @State private var vehicle: CarrisNetworkModel.Vehicle?
   
   var body: some View {
      VStack {
         switch (vehicle?.kind) {
            case .tram, .elevator:
               Image("Tram")
            case .neighborhood, .night, .regular, .none:
               Image("RegularService")
         }
      }
      .rotationEffect(.radians(vehicle?.angleInRadians ?? 0) + .degrees(-mapController.mapCamera.heading))
      .animation(.default, value: vehicle?.angleInRadians)
      .onAppear() {
         self.vehicle = carrisNetworkController.find(vehicle: self.vehicleId)
      }
   }
   
}









// ROUTE VARIANT OVERLAY RENDERER


//final class VehicleMKAnnotationView: MKOverlayRenderer {
//
//   static let reuseIdentifier = "vehicle"
//
//   override var annotation: MKAnnotation? {
//      willSet {
//         guard let newValue = newValue as? GeoBusMKAnnotation else { return }
//
//         canShowCallout = false
//
//         zPriority = MKAnnotationViewZPriority(1)
//
//         let swiftUIView = VehicleSwiftUIAnnotationView(vehicleId: newValue.id)
//         let uiKitView = UIHostingController(rootView: swiftUIView)
//         addSubview(uiKitView.view)
//      }
//   }
//
//}
