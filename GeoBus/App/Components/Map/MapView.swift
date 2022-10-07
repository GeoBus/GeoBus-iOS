//
//  MapView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import MapKit


struct MapView: UIViewRepresentable {
   
   let landmarks = [LandmarkAnnotation(
      title: "Test",
      subtitle: "Test subtitle",
      coordinate: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732)
   )]
   
   func makeCoordinator() -> MapViewCoordinator{
      MapViewCoordinator(self)
   }
   
   func makeUIView(context: Context) -> MKMapView{
      MKMapView(frame: .zero)
   }
   
   func updateUIView(_ view: MKMapView, context: Context) {
      
      view.delegate = context.coordinator
      
      let region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732),
         latitudinalMeters: 15000, longitudinalMeters: 15000
      )
      view.setRegion(region, animated: true)
      view.addAnnotations(landmarks)
      
      view.register(TestAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

   }
   
}



class MapViewCoordinator: NSObject, MKMapViewDelegate {
   
   var mapViewController: MapView
   
   init(_ control: MapView) {
      self.mapViewController = control
   }
   
   func mapView(_ mapView: MKMapView, viewFor
                annotation: MKAnnotation) -> MKAnnotationView?{
      //Custom View for Annotation
      let annotationView = TestAnnotationView(annotation: annotation, reuseIdentifier: "customView")
      annotationView.canShowCallout = false
      //Your custom image icon
//      annotationView.image = UIImage(systemName: "pencil.circle.fill")
      
      return annotationView
   }
}



class TestAnnotationView: MKAnnotationView {
   
   
   override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
      
      frame = CGRect(x: 0, y: 0, width: 40, height: 50)
      centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
      
      canShowCallout = true
      setupUI()
   }
   
   @available(*, unavailable)
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   
   private func setupUI() {
      backgroundColor = .clear
      
      let swiftUIView = SwiftUITestAnnotationView()
      lazy var hostingViewController = UIHostingController(rootView: swiftUIView)
      
      self.addSubview(hostingViewController.view)
      
//      view.frame = bounds
   }

}



struct SwiftUITestAnnotationView: View {
   
   @State private var isPresented: Bool = false
   @State private var viewSize = CGSize()
   
   
   var body: some View {
      Button(action: {
         self.isPresented = !self.isPresented
      }) {
         if (isPresented) {
            Image("GreenInfo")
         } else {
            Image("PinkArrowUp")
         }
      }
      .frame(width: 40, height: 40, alignment: .center)
      .sheet(isPresented: $isPresented) {
         VStack(alignment: .leading) {
            Text("hey hey")
            Disclaimer()
               .padding(.horizontal)
               .padding(.bottom, 10)
         }
         .readSize { size in
            viewSize = size
         }
         .presentationDetents([.height(viewSize.height)])
      }
   }
   
}



class LandmarkAnnotation: NSObject, MKAnnotation {
   let title: String?
   let subtitle: String?
   let coordinate: CLLocationCoordinate2D
   init(title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D) {
      self.title = title
      self.subtitle = subtitle
      self.coordinate = coordinate
   }
}








//struct MapView: View {
//
//   @EnvironmentObject var mapController: MapController
//   @EnvironmentObject var stopsController: StopsController
//   @EnvironmentObject var routesController: RoutesController
//   @EnvironmentObject var vehiclesController: VehiclesController
//
//
//   var body: some View {
//      Map(
//         coordinateRegion: $mapController.region,
//         interactionModes: [.all],
//         showsUserLocation: true,
//         annotationItems: mapController.visibleAnnotations
//      ) { annotation in
//
//         MapAnnotation(coordinate: annotation.location) {
//            switch (annotation.format) {
//               case .stop:
//                  StopAnnotationView(stop: annotation.stop!, isPresentedOnAppear: false)
//               case .vehicle:
//                  VehicleAnnotationView(vehicle: annotation.vehicle!, isPresentedOnAppear: false)
//               case .singleStop:
//                  StopAnnotationView(stop: annotation.stop!, isPresentedOnAppear: true)
//            }
//         }
//
//      }
//      .onChange(of: stopsController.selectedStop) { newStop in
//         if (newStop != nil) {
//            mapController.updateAnnotations(with: newStop!)
//         }
//      }
//      .onChange(of: routesController.selectedVariant) { newVariant in
//         if (newVariant != nil) {
//            mapController.updateAnnotations(with: newVariant!)
//         }
//      }
//      .onChange(of: vehiclesController.vehicles) { newVehiclesList in
//         mapController.updateAnnotations(with: newVehiclesList)
//      }
//   }
//
//
//}
