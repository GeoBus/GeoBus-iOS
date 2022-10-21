import Foundation

/* * */
/* MARK: - CARRIS API DATA MODEL */
/* Data model as provided by Carris API. */
/* Schema is available at https://joaodcp.github.io/Carris-API */

struct CarrisAPIModel {
   
   struct RoutesList: Decodable {
      let id: Int?
      let routeNumber: String?
      let name: String?
      let isPublicVisible: Bool?
      let timestamp: String?
   }
   
   struct Route: Decodable {
      let isCirc: Bool?
      let variants: [Variant]?
      let id: Int?
      let routeNumber: String?
      let name: String?
      let isPublicVisible: Bool?
      let timestamp: String?
   }
   
   struct Variant: Decodable {
      let id: Int?
      let variantNumber: Int?
      let isActive: Bool?
      let upItinerary, downItinerary, circItinerary: Itinerary?
   }
   
   struct Itinerary: Decodable {
      let id: Int?
      let type: String?
      let connections: [Connection]?
   }
   
   struct Connection: Decodable {
      let id, distance, orderNum: Int?
      let busStop: Stop?
   }
   
   struct Stop: Decodable {
      let id: Int?
      let name, publicId: String?
      let lat, lng: Double?
      let isPublicVisible: Bool?
      let timestamp: String?
   }
   
   struct VehicleSummary: Decodable {
      let busNumber: Int?
      let state: String?
      let lastGpsTime: String?
      let lastReportTime: String?
      let lat: Double?
      let lng: Double?
      let routeNumber: String?
      let direction: String?
      let plateNumber: String?
      let timeStamp: String?
      let dataServico: String?
      let previousReportTime: String?
      let previousLatitude: Double?
      let previousLongitude: Double?
   }
   
   struct VehicleDetail: Decodable {
      let vehiclePlate: String?
      let routeNumber: String?
      let plateNumber: String?
      let direction: String?
      let lastStopOnVoyageId: Int?
      let lastStopOnVoyageName: String?
      let parkingStopId: Int?
      let parkingStopName: String?
      let driverNumber: String?
      let lat: Double?
      let lng: Double?
   }
   
   struct Estimation: Decodable {
      let routeNumber: String?
      let routeName: String?
      let destination: String?
      let time: String? // Expected time of arrival
      let busNumber: String?
      let plateNumber: String?
      let voyageNumber: Int
      let publicId: String?
   }
   
}
