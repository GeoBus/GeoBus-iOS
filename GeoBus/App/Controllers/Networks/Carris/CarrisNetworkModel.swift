import Foundation
import CoreLocation


/* * */
/* MARK: - CARRIS NETWORK DATA MODEL */
/* Data provided by the Carris API consists of a list of separate endpoints */
/* from which it is possible to retrieve information from routes and stops. */
/* For this app, the goal is to simplify and build upon this network model */
/* to prevent duplicated data and increase flexibility on updates to the views. */


struct CarrisNetworkModel {
   
   enum Kind: Codable, Equatable {
      case tram
      case neighborhood
      case night
      case elevator
      case regular
   }
   
   
   enum Direction: Codable {
      case circular
      case ascending
      case descending
   }
   
   
   // ROUTE
   // Routes are identified by its ‹routeNumber›, have a name,
   // a kind (tram, nightBus, etc.) and can have several variants.
   struct Route: Codable, Equatable, Identifiable {
      let id: String
      let number: String
      let name: String
      let kind: Kind
      let variants: [Variant]
      
      init(number: String, name: String, kind: Kind, variants: [Variant]) {
         self.id = number
         self.number = number
         self.name = name
         self.kind = kind
         self.variants = variants
      }
   }
   
   
   // VARIANT
   // Variants are alternative paths the same route can have,
   // like segments of a full route during peak hours.
   // Variants are identified by its number inside each route,
   // and they can be circular or in a straight line.
   struct Variant: Codable, Equatable, Identifiable {
      let id: Int
      let number: Int
      let name: String
      let circularItinerary: [Connection]?
      let ascendingItinerary: [Connection]?
      let descendingItinerary: [Connection]?
      
      let circularShape: String?
      
      init(number: Int, name: String, circularItinerary: [Connection]? = nil, ascendingItinerary: [Connection]? = nil, descendingItinerary: [Connection]? = nil, circularShape: String?) {
         self.id = number
         self.number = number
         self.name = name
         self.circularItinerary = circularItinerary
         self.ascendingItinerary = ascendingItinerary
         self.descendingItinerary = descendingItinerary
         self.circularShape = circularShape
      }
   }
   
   
   // CONNECTION
   // Connections are a thin wrapper before stops in order to be able
   // to hold a ‹orderInRoute› number. Connections are identified by this value.
   struct Connection: Codable, Equatable, Identifiable {
      let id: Int
      let direction: Direction
      let orderInRoute: Int
      let stop: Stop
      
      init(direction: Direction, orderInRoute: Int, stop: Stop) {
         self.id = stop.id
         self.direction = direction
         self.orderInRoute = orderInRoute
         self.stop = stop
      }
   }
   
   
   /* * */
   /* MARK: - STOP */
   /* Stops are identified by its ‹publicId› value. */
   /* They have a name and a location. */
   struct Stop: Codable, Equatable, Identifiable {
      let id: Int
      let name: String
      let lat, lng: Double
      
      init(id: Int, name: String, lat: Double, lng: Double) {
         self.id = id
         self.name = name
         self.lat = lat
         self.lng = lng
      }
   }
   
   
   /* * */
   /* MARK: - ESTIMATION */
   /* Lorem ipsum. */
   struct Estimation: Codable, Identifiable, Equatable {
      let id: UUID
      let stopId: Int
      let routeNumber: String?
      let destination: String?
      let eta: String?
      let hasArrived: Bool
      let idleSeconds: Int
      let busNumber: Int?
      
      init(stopId: Int, routeNumber: String?, destination: String?, eta: String?, busNumber: Int? = nil, idleSeconds: Int?, hasArrived: Bool?) {
         self.id = UUID()
         self.stopId = stopId
         self.routeNumber = routeNumber
         self.destination = destination
         self.busNumber = busNumber
         self.eta = eta
         self.hasArrived = hasArrived ?? false
         self.idleSeconds = idleSeconds ?? 0
      }
   }
   
   
   
   /* * */
   /* MARK: - CARRIS VEHICLE */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia. */
   
   class Vehicle: Identifiable, Equatable {
      
      static func == (lhs: CarrisNetworkModel.Vehicle, rhs: CarrisNetworkModel.Vehicle) -> Bool {
         return false
      }
      
      
      // IDENTIFIER
      // The unique identifier for this model.
      
      let id: Int // Bus Number
      
      init(id: Int, routeNumber: String, lat: Double, lng: Double, previousLatitude: Double, previousLongitude: Double, lastGpsTime: String) {
         self.id = id
         self.routeNumber = routeNumber
         self.lat = lat
         self.lng = lng
         self.previousLatitude = previousLatitude
         self.previousLongitude = previousLongitude
         self.lastGpsTime = lastGpsTime
      }
      
      
      
      /* * */
      /* MARK: - STATIC PROPERTIES */
      /* The data for this model. Here they are separated from the ones */
      /* retrieved from Carris API and from other community sources. */
      
      // From Carris API › Vehicle Summary
      var routeNumber: String?
      var lat: Double?
      var lng: Double?
      var previousLatitude: Double?
      var previousLongitude: Double?
      var lastGpsTime: String?
      var direction: Direction?
      
      // Carris API › Vehicle Details
      var vehiclePlate: String?
      var lastStopOnVoyageId: Int?
      var lastStopOnVoyageName: String?
      var hasLoadedCarrisDetails: Bool = false
      
      // Community API
      var routeOverview: [Estimation]?
      var hasLoadedCommunityDetails: Bool = false
      
      
      
      /* * */
      /* MARK: - COMPUTED PROPERTIES */
      /* The data for this model. Here they are separated from the ones */
      /* retrieved from Carris API and from other community sources. */
      
      var coordinate: CLLocationCoordinate2D {
         return CLLocationCoordinate2D(
            latitude: self.lat ?? 0,
            longitude: self.lng ?? 0
         )
      }
      
      var previousCoordinate: CLLocationCoordinate2D {
         return CLLocationCoordinate2D(
            latitude: self.previousLatitude ?? 0,
            longitude: self.previousLongitude ?? 0
         )
      }
      
      var kind: Kind? {
         return Helpers.getKind(by: self.routeNumber ?? "")
      }
      
      var angleInRadians: Double? {
         return Helpers.getAngleInRadians(
            prevLat: previousCoordinate.latitude,
            prevLng: previousCoordinate.longitude,
            currLat: coordinate.latitude,
            currLng: coordinate.longitude
         )
      }
      
      
   }
   
   
}
