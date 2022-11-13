import Foundation
import MapKit


/* * */
/* MARK: - MAP CONTROLLER */
/* Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi rutrum lectus */
/* non interdum imperdiet. In hendrerit ligula velit, ac porta augue volutpat id. */


@MainActor
final class MapController: ObservableObject {
   
   /* * */
   /* MARK: - SECTION 1: SETTINGS */
   /* Static settings for the Map view. */
   
   private let initialMapRegion = CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732)
   private let initialMapZoom = CLLocationDistance(15000)
   
   private let annotationsZoomMargin = 1.7 // The margin on the sides of the annotations
   
   
   
   /* * */
   /* MARK: - SECTION 2: PUBLISHED PROPERTIES */
   /* Here are all the @Published variables that can be consumed by the app views. */
   
   @Published var region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 38.721917, longitude: -9.137732),
      span: MKCoordinateSpan(latitudeDelta: CLLocationDistance(15000), longitudeDelta: CLLocationDistance(15000))
   )
   
   
   @Published var mapCamera: MKMapCamera = MKMapCamera()
   
   
   @Published var locationManager = CLLocationManager()
   @Published var showLocationNotAllowedAlert: Bool = false
   
   @Published var visibleAnnotations: [GenericMapAnnotation] = []
   
   
   @Published var allAnnotations: [GeoBusMKAnnotation] = []
   @Published var allOverlays: [MKPolyline] = []
   
   
   /* * */
   /* MARK: - SECTION 3: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   public static let shared = MapController()
   
   
   
   /* * */
   /* MARK: - SECTION 4: INITIALIZER */
   /* Protect the initializer to ensure only one instance of this class is created. */
   /* Setup the initial map region on init. */
   
   private init() {
      self.region = MKCoordinateRegion(
         center: self.initialMapRegion,
         latitudinalMeters: self.initialMapZoom,
         longitudinalMeters: self.initialMapZoom
      )
   }
   
   
   
   
   
   
   // ADD ANNOTATIONS
   func add(annotations newAnnotationsArray: [GeoBusMKAnnotation], ofType annotationsType: GeoBusMKAnnotation.AnnotationType) {
      self.allAnnotations.removeAll(where: { $0.type == annotationsType })
      self.allAnnotations.append(contentsOf: newAnnotationsArray)
   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 5: MOVE MAP TO NEW COORDINATE REGION */
   /* Helper function to animate the Map changing region. */
   
   func moveMap(to newRegion: MKCoordinateRegion) {
      self.region = newRegion
   }
   
   
   
   /* * */
   /* MARK: - SECTION 6: CENTER MAP ON COORDINATES */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func centerMapOnCoordinates(lat: Double, lng: Double, andZoom: Bool = false) {
      self.region = MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
         span: self.region.span
      )
   }
   
   
   
   /* * */
   /* MARK: - SECTION 6: CENTER MAP ON USER LOCATION */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func centerMapOnUserLocation(andZoom: Bool) {
      
      locationManager.requestWhenInUseAuthorization()
      
      if (locationManager.authorizationStatus == .authorizedWhenInUse) {
         Analytics.shared.capture(event: .Location_Status_Allowed)
         if (andZoom) {
            self.moveMap(to: MKCoordinateRegion(
               center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
               latitudinalMeters: 400, longitudinalMeters: 400
            ))
         } else {
            self.moveMap(to: MKCoordinateRegion(
               center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
               span: region.span
            ))
         }
      } else if (locationManager.authorizationStatus != .notDetermined) {
         Analytics.shared.capture(event: .Location_Status_Denied)
         self.showLocationNotAllowedAlert = true
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 7: ZOOM MAP TO FIT ANNOTATIONS */
   /* Given an array of annotations, calculate the 4 coordinates that encompass */
   /* all of them in the map, give them a little padding on all sides, and move the map. */
   
   func zoomToFitMapAnnotations(annotations: [GenericMapAnnotation]) {
      guard annotations.count > 0 else {
         return
      }
      
      var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
      
      for annotation in annotations {
         topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.location.longitude)
         topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.location.latitude)
         bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.location.longitude)
         bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.location.latitude)
      }
      
      var newRegion: MKCoordinateRegion = MKCoordinateRegion()
      newRegion.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
      newRegion.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
      newRegion.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * annotationsZoomMargin
      newRegion.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * annotationsZoomMargin
      
      self.moveMap(to: newRegion)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8: UPDATE ANNOTATIONS WITH SELECTED CARRIS STOP */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
//   func updateAnnotations(with activeStop: CarrisNetworkModel.Stop) {
//
//      visibleAnnotations.removeAll(where: {
//         switch $0.item {
//            case .stop(_), .carris_connection(_), .vehicle(_:
//               return true
//         }
//      })
//
//      var tempNewAnnotations: [GenericMapAnnotation] = []
//
//      tempNewAnnotations.append(
//         GenericMapAnnotation(
//            id: UUID(),
//            location: CLLocationCoordinate2D(latitude: activeStop.lat, longitude: activeStop.lng),
//            item: .stop(activeStop)
//         )
//      )
//
//      self.addAnnotations(tempNewAnnotations, zoom: true)
//
//   }
   
   
   
   /* * */
   /* MARK: - SECTION 9: UPDATE ANNOTATIONS WITH SELECTED CARRIS VARIANT */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(with activeVariant: CarrisNetworkModel.Variant) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .carris_connection(_), .stop(_):
               return true
            case .vehicle(_):
               return false
         }
      })
      
      
      var tempNewAnnotations: [GenericMapAnnotation] = []
      
      
      if (activeVariant.circularItinerary != nil) {
         for connection in activeVariant.circularItinerary! {
            tempNewAnnotations.append(
               GenericMapAnnotation(
                  id: UUID(),
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      if (activeVariant.ascendingItinerary != nil) {
         for connection in activeVariant.ascendingItinerary! {
            tempNewAnnotations.append(
               GenericMapAnnotation(
                  id: UUID(),
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      if (activeVariant.descendingItinerary != nil) {
         for connection in activeVariant.descendingItinerary! {
            tempNewAnnotations.append(
               GenericMapAnnotation(
                  id: UUID(),
                  location: CLLocationCoordinate2D(latitude: connection.stop.lat, longitude: connection.stop.lng),
                  item: .carris_connection(connection)
               )
            )
         }
      }
      
      self.addAnnotations(tempNewAnnotations, zoom: true)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 10: UPDATE ANNOTATIONS WITH LIST OF ACTIVE CARRIS VEHICLES */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(with activeVehiclesList: [CarrisNetworkModel.Vehicle]) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .vehicle(_), .stop(_):
               return true
            case .carris_connection(_):
               return false
         }
      })
      
      
      var tempNewAnnotations: [GenericMapAnnotation] = []
      
      for vehicle in activeVehiclesList {
         tempNewAnnotations.append(
            GenericMapAnnotation(
               id: UUID(),
               location: vehicle.coordinate,
               item: .vehicle(vehicle)
            )
         )
      }
      
      self.addAnnotations(tempNewAnnotations)
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 10: UPDATE ANNOTATIONS WITH SINGLE ACTIVE CARRIS VEHICLE */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(with activeVehicle: CarrisNetworkModel.Vehicle) {
      
//      let indexOfVehicleInArray = allVehicles.firstIndex(where: {
//         $0.id == vehicleId
//      })
      
      
      if let activeVehicleAnnotation = visibleAnnotations.first(where: {
         switch $0.item {
            case .vehicle(let item):
               if (item.id == activeVehicle.id) {
                  return true
               } else {
                  return false
               }
            case .carris_connection(_), .stop(_):
               return false
         }
         }) {
         
         self.zoomToFitMapAnnotations(annotations: [activeVehicleAnnotation])
            
      } else {
         
         var tempNewAnnotations: [GenericMapAnnotation] = []
         
         tempNewAnnotations.append(
            GenericMapAnnotation(
               id: UUID(),
               location: activeVehicle.coordinate,
               item: .vehicle(activeVehicle)
            )
         )
         
         self.addAnnotations(tempNewAnnotations, zoom: true)
         
      }
      
   }
   
   
   
   
   
   
   
   
   
   
   private func addAnnotations(_ newAnnotations: [GenericMapAnnotation], zoom: Bool = false) {
      DispatchQueue.main.async {
         // Add the annotations to the map
         self.visibleAnnotations.append(contentsOf: newAnnotations)
         // Remove annotations with duplicate IDs (ex: same stop on different itineraries)
         self.visibleAnnotations.uniqueInPlace(for: \.id)
         // Adjust map region to annotations
         if (zoom) {
            self.zoomToFitMapAnnotations(annotations: newAnnotations)
         }
      }
   }
   
   
//   private func removeAnnotations(ofType annotationTypes: [GenericMapAnnotation.AnnotationItem]) {
//      visibleAnnotations.removeAll(where: {
//         for type in annotationTypes {
//            if ($0.item == type) {
//               return true
//            }
//         }
//         return false
//      })
//   }
   
   
   
   
   
   /* * */
   /* MARK: - SECTION 8: UPDATE ANNOTATIONS WITH SELECTED CARRIS STOP */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   func updateAnnotations(ministop: [CarrisNetworkModel.Stop]) {
      
      visibleAnnotations.removeAll(where: {
         switch $0.item {
            case .stop(_):
               return true
            case .vehicle(_), .carris_connection(_):
               return false
         }
      })
      
      var tempNewAnnotations: [GenericMapAnnotation] = []
      
      for stop in ministop {
         tempNewAnnotations.append(
            GenericMapAnnotation(
               id: UUID(),
               location: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lng),
               item: .stop(stop)
            )
         )
      }
      
      self.addAnnotations(tempNewAnnotations, zoom: true)
      
   }
   
   
   /* * */
   /* MARK: - SECTION 8: UPDATE ANNOTATIONS WITH SELECTED CARRIS STOP */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. */
   
   private var allStopAnnotations: [GenericMapAnnotation] = []
   
   func updateAnnotations(for newMapRegion: MKCoordinateRegion?, with allStops: [CarrisNetworkModel.Stop]) {
      
      if (allStopAnnotations.isEmpty) {
         for stop in allStops {
            allStopAnnotations.append(
               GenericMapAnnotation(
                  id: UUID(),
                  location: CLLocationCoordinate2D(latitude: stop.lat, longitude: stop.lng),
                  item: .stop(stop)
               )
            )
         }
      }
      
      
      if (region.span.latitudeDelta < 0.005 || region.span.longitudeDelta < 0.005) {
         
         let latTop = self.region.center.latitude + self.region.span.latitudeDelta
         let latBottom = self.region.center.latitude - self.region.span.latitudeDelta
         
         let lngRight = self.region.center.longitude + self.region.span.longitudeDelta
         let lngLeft = self.region.center.longitude - self.region.span.longitudeDelta
         
         
         for annotation in allStopAnnotations {
            
            // Checks
            let isBetweenLats = annotation.location.latitude > latBottom && annotation.location.latitude < latTop
            let isBetweenLngs = annotation.location.longitude > lngLeft && annotation.location.longitude < lngRight
            
            if (isBetweenLats && isBetweenLngs) {
               if visibleAnnotations.firstIndex(where: {
                  $0.id == annotation.id
               }) == nil {
                  visibleAnnotations.append(annotation)
               }
            } else {
               if let indexOfAnnotation = visibleAnnotations.firstIndex(where: {
                  $0.id == annotation.id
               }) {
                  visibleAnnotations.remove(at: indexOfAnnotation)
               }
            }
            
         }
         
      } else {
         visibleAnnotations.removeAll(where: {
            switch $0.item {
               case .stop(_):
                  return true;
               case .carris_connection(_), .vehicle(_):
                  return false;
            }
         })
      }
      
   }
   
   
}





extension MKCoordinateRegion: Equatable {
   public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
      if (lhs.center.latitude != rhs.center.latitude) { return false }
      if (lhs.center.longitude != rhs.center.longitude) { return false }
      if (lhs.span.latitudeDelta != rhs.span.latitudeDelta) { return false }
      if (lhs.span.longitudeDelta != rhs.span.longitudeDelta) { return false }
      return true
   }
}


extension CLLocationCoordinate2D: Equatable {
   public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
      if (lhs.latitude != rhs.latitude) { return false }
      if (lhs.longitude != rhs.longitude) { return false }
      return true
   }
}
