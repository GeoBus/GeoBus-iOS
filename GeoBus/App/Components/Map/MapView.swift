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

   let landmarks = [
      LandmarkAnnotation(
         title: "Test",
         subtitle: "Test subtitle",
         coordinate: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732)
      )
   ]

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
   
   
   func drawRoute(routeData: [CLLocation]) {
      if routeData.count == 0 {
         print("🟡 No Coordinates to draw")
         return
      }
      
      let coordinates = routeData.map { location -> CLLocationCoordinate2D in
         return location.coordinate
      }
      
      DispatchQueue.main.async {
         self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
         self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
         let customEdgePadding : UIEdgeInsets = UIEdgeInsets(
            top: 50,
            left: 50,
            bottom: 50,
            right: 50
         )
         self.mapView.setVisibleMapRect(self.routeOverlay!.boundingMapRect, edgePadding: customEdgePadding,animated: true)
      }
   }

}



class MapViewCoordinator: NSObject, MKMapViewDelegate {

   var mapViewController: MapView

   init(_ control: MapView) {
      self.mapViewController = control
   }

   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
      //Custom View for Annotation
      let annotationView = TestAnnotationView(annotation: annotation, reuseIdentifier: "customView")
      annotationView.canShowCallout = false
      //Your custom image icon
//      annotationView.image = UIImage(systemName: "pencil.circle.fill")

      return annotationView
   }


   func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//      print("GB3: \(view)")
      if let annotation = view.annotation, annotation.isKind(of: LandmarkAnnotation.self) {
         print("GB3: \(annotation)")
      }
   }

   func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
//      annotation.
   }

}



class TestAnnotationView: MKAnnotationView {


   override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

      frame = CGRect(x: 0, y: 0, width: 40, height: 50)
      centerOffset = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)

      canShowCallout = false
      setupUI()
   }

   @available(*, unavailable)
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }


   private func setupUI() {
      backgroundColor = .clear

      let swiftUIView = SwiftUITestAnnotationView(isPresented: false)
      lazy var hostingViewController = UIHostingController(rootView: swiftUIView)

      self.addSubview(hostingViewController.view)

//      view.frame = bounds
   }


   func annotationWasSelected() {
      let swiftUIView = SwiftUITestAnnotationView(isPresented: true)
      lazy var hostingViewController = UIHostingController(rootView: swiftUIView)

      self.addSubview(hostingViewController.view)
   }

}



struct SwiftUITestAnnotationView: View {

   @State var isPresented: Bool
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
   let swiftUIView: any View
   init(title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D) {
      self.title = title
      self.subtitle = subtitle
      self.coordinate = coordinate
      self.swiftUIView = SwiftUITestAnnotationView(isPresented: false)
   }
}



