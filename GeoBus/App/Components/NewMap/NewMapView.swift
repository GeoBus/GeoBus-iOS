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
   @Binding var annotations: [GeoBusMKAnnotation]
   
   
   func makeUIView(context: UIViewRepresentableContext<MapViewSwiftUI>) -> MKMapView {
      mapView.delegate = context.coordinator
      mapView.region = self.region
      mapView.showsUserLocation = true
      mapView.userTrackingMode = .follow
      
      mapView.register(StopMKAnnotationView.self, forAnnotationViewWithReuseIdentifier: StopMKAnnotationView.reuseIdentifier)
      
      return mapView
   }
   
   
   func updateUIView(_ uiView: MKMapView, context: Context) {
      
      // First, make sure we are dealing with annotation of type GeoBusMKAnnotation
      guard let currentAnnotations = uiView.annotations as? [GeoBusMKAnnotation] else { return }
      
      // Find out the excess annotations that should be removed from the map
      // The following works as: [a, b, c, d, e] - [a, c, e] = [b, d]
      let annotationsToRemove = Array(Set(currentAnnotations).subtracting(annotations))
      
      // Update the view with annotations
      uiView.removeAnnotations(annotationsToRemove)
      uiView.addAnnotations(annotations)
      
      print("HOWMANY removeAnnotations: \(annotationsToRemove.count)")
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
   
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard let annotation = annotation as? GeoBusMKAnnotation else { return nil }
      
      switch annotation.type {
         case .stop:
            return mapView.dequeueReusableAnnotationView(withIdentifier: StopMKAnnotationView.reuseIdentifier, for: annotation)
         default:
            return nil
      }
      
   }
   
   
   func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
      guard let annotation = annotation as? GeoBusMKAnnotation else { return nil }
      
      switch annotation.type {
         case .stop:
            return \\ activate stop in CarrisNetworkController
         default:
            return nil
      }
   }
   
}






final class GeoBusMKAnnotation: NSObject, MKAnnotation {
   
   let id: Int
   let type: AnnotationType
   var coordinate: CLLocationCoordinate2D
   
   enum AnnotationType {
      case stop
      case vehicle
   }
   
   init(id: Int, coordinate: CLLocationCoordinate2D, type: AnnotationType) {
      self.id = id
      self.coordinate = coordinate
      self.type = type
   }
   
   override func isEqual(_ object: Any?) -> Bool {
      if let annot = object as? GeoBusMKAnnotation{
         // Add your defintion of equality here. i.e what determines if two Annotations are equal.
         let equalCoordinates = annot.coordinate == self.coordinate
         let equalType = annot.type == self.type
         return equalCoordinates && equalType
//         return annot.id == id
//         return annot.coordinate.latitude == coordinate.latitude && annot.coordinate.longitude == coordinate.longitude
      }
      return false
   }
   
}


final class StopMKAnnotationView: MKAnnotationView {
   
   static let reuseIdentifier = "stop"
   
   override var annotation: MKAnnotation? {
      willSet {
         guard let newValue = newValue as? GeoBusMKAnnotation else { return }
         
//         clusteringIdentifier = "stop"
         canShowCallout = false
         
         let swiftUIView = NewStopMKAnnotationView(stopId: newValue.id)
         let uiKitView = UIHostingController(rootView: swiftUIView)
         addSubview(uiKitView.view)
         
      }
      
   }
   
}








// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------






struct NewMapView: UIViewRepresentable {
   
   private let mapView = MKMapView()
   
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   func makeUIView(context: UIViewRepresentableContext<NewMapView>) -> MKMapView {
      
      mapView.delegate = context.coordinator
      mapView.mapType = MKMapType.standard
      mapView.showsUserLocation = true
      mapView.showsTraffic = true
      mapView.isRotateEnabled = true
      mapView.isPitchEnabled = true
      
      mapView.register(NewStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: "stop")
      
      // Set initial location in Lisbon
      let lisbon = CLLocation(latitude: 38.721917, longitude: -9.137732)
      let lisbonArea = MKCoordinateRegion(center: lisbon.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
      mapView.setRegion(lisbonArea, animated: true)
      
      return mapView
   }
   
   
   
   
   
//   override func viewDidLoad() {
//      super.viewDidLoad()
//      setupCompassButton()
//      setupUserTrackingButtonAndScaleView()
//      registerAnnotationViewClasses()
//
//      locationManager.delegate = self
//      locationManager.requestWhenInUseAuthorization()
//      locationManager.startUpdatingLocation()
//
//      loadDataForMapRegionAndBikes()
//   }
   
   
   
   func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<NewMapView>) {
      
      print("MAPTEST: is called updateUIView")
//      print("MAPTEST: carrisNetworkController.activeRoute: \(carrisNetworkController.activeRoute)")
      
      
      if (uiView.annotations.isEmpty) {
         
         var annotationsToAdd: [MKAnnotation] = []
         
         carrisNetworkController.allStops.forEach({
            annotationsToAdd.append(
               NewStopAnnotation(
                  name: $0.name,
                  publicId: $0.id,
                  latitude: $0.lat,
                  longitude: $0.lng,
                  stop: $0
               )
            )
         })
         
         uiView.addAnnotations(annotationsToAdd)
         
      }
      
      
      // Update whatever was set to update
//      uiView.removeAnnotations(uiView.annotations)
//      uiView.addAnnotations(annotationsToAdd)
      
//      uiView.showAnnotations(annotationsToAdd, animated: true)
      
   }
   
   
   func makeCoordinator() -> NewMapView.Coordinator {
      Coordinator(control: self)
   }
   
   
   
   // MARK: - MKMapViewDelegate
   
   final class Coordinator: NSObject, MKMapViewDelegate {
      
      private let control: NewMapView
      
      private let sheetController = SheetController.shared
      private let carrisNetworkController = CarrisNetworkController.shared
      
      init(control: NewMapView) {
         self.control = control
      }
      
      
      
//      @MainActor func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//         print("MAPTEST: mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)")
//         if view.isKind(of: NewConnectionAnnotationView.self) {
//
//            let selectedStopAnnotationView = view as! NewConnectionAnnotationView
//            let stopAnnotation = selectedStopAnnotationView.annotation as! NewConnectionAnnotation
//
////            selectedStopAnnotationView.marker.image = UIImage(named: "GreenInfo")
//
//            TapticEngine.impact.feedback(.light)
//            _ = carrisNetworkController.select(connection: stopAnnotation.connection)
//            sheetController.present(sheet: .ConnectionDetails)
//
//         }
//      }
      
      
      @MainActor func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
         print("MAPTEST: mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)")
         if annotation.isKind(of: NewStopAnnotation.self) {
            
            let stopAnnotation = annotation as! NewStopAnnotation
            
            print("MAPTEST: selected annotation stop id: \(stopAnnotation.stop.id)")
            
            TapticEngine.impact.feedback(.light)
            _ = carrisNetworkController.select(stop: stopAnnotation.stop)
            sheetController.present(sheet: .ConnectionDetails)
            
         }
      }
      
      
      
      @MainActor func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
         print("MAPTEST: mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)")
//         if view.isKind(of: NewConnectionAnnotationView.self) {
//
////            let selectedStopAnnotationView = view as! NewConnectionAnnotationView
////            let stopAnnotation = selectedStopAnnotationView.annotation as! NewConnectionAnnotation
//
////            selectedStopAnnotationView.marker.image = stopAnnotation.markerSymbol
//
            carrisNetworkController.deselect([.stop])
//
//         }
      }
      
      
      
      
      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         guard let annotation = annotation as? NewStopAnnotation else { return nil }
         
         let identifier = "stop"
         var view: MKAnnotationView
         
         if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequeuedView.annotation = annotation
            view = dequeuedView
         } else {
            view = NewStopAnnotationView(annotation: annotation, reuseIdentifier: NewStopAnnotationView.ReuseID) //MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
         }
         
         return view
//         return NewStopAnnotationView(annotation: annotation, reuseIdentifier: NewStopAnnotationView.ReuseID)
      }
      
      
//      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//         print("MAPTEST: mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?")
//         if annotation.isKind(of: NewStopAnnotation.self) {
//
////            return MKAnnotationView(annotation: annotation, reuseIdentifier: "stop")
//
//            let identifier = "stop"
//            var view: MKAnnotationView
//
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
//               dequeuedView.annotation = annotation
//               view = dequeuedView
//            } else {
//               view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            }
////
//             return view
//
//         } else {
//
//            return nil
//
//         }
//
//      }
      
      
   }
   
}






class NewStopAnnotationView: MKAnnotationView {
   
   static let ReuseID = "stop"
   
//   override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
//      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
//      clusteringIdentifier = "stop"
//   }
//
//   required init?(coder aDecoder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//   }
   
//   override func prepareForDisplay() {
//      super.prepareForDisplay()
//      displayPriority = .defaultLow
////      markerTintColor = UIColor.unicycleColor
////      glyphImage = #imageLiteral(resourceName: "unicycle")
//      let swiftUIView = Circle().foregroundColor(.blue).frame(width: 5, height: 5) // swiftUIView is View
//      let viewCtrl = UIHostingController(rootView: swiftUIView)
//      addSubview(viewCtrl.view)
//   }
   
   override var annotation: MKAnnotation? {

      willSet {
         guard let annotation = newValue as? NewStopAnnotation else {
            return
         }

         clusteringIdentifier = "stop"
         canShowCallout = false

         let swiftUIView = StopAnnotationView(stop: annotation.stop) // swiftUIView is View
         let viewCtrl = UIHostingController(rootView: swiftUIView)
         addSubview(viewCtrl.view)

      }

   }
   
   
   
}



class NewStopAnnotation: NSObject, MKAnnotation {
   
   let name: String
   let publicId: Int
   
   let coordinate: CLLocationCoordinate2D
   
   let stop: CarrisNetworkModel.Stop
   
   
   init(name: String?, publicId: Int?, latitude: Double, longitude: Double, stop: CarrisNetworkModel.Stop) {
      self.name = name ?? "-"
      self.publicId = publicId ?? -1
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.stop = stop
      super.init()
   }
   
}

