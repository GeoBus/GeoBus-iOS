import Foundation
import MapKit


/* * */
/* MARK: - CARRIS VEHICLE */
/* Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia. */


class CarrisVehicle: Identifiable, Equatable {
   
   static func == (lhs: CarrisVehicle, rhs: CarrisVehicle) -> Bool {
      return
         lhs.id == rhs.id &&
         lhs.coordinate?.latitude == rhs.coordinate?.latitude &&
         lhs.coordinate?.longitude == rhs.coordinate?.longitude &&
         lhs.routeNumber == rhs.routeNumber
   }
   
   
   public init(id: Int, routeNumber: String?, lat: Double?, lng: Double?, previousLatitude: Double?, previousLongitude: Double?, lastGpsTime: String?) {
      self.id = id
      self.lat = lat
      self.lng = lng
      self.previousLatitude = previousLatitude
      self.previousLongitude = previousLongitude
      self.lastGpsTime = lastGpsTime
   }
   
   
   /* * */
   /* MARK: - SECTION 1: IDENTIFIER */
   /* The unique identifier for this model. */
   
   public let id: Int // Bus Number
   
   
   
   /* * */
   /* MARK: - SECTION 2: VEHICLE PROPERTIES */
   /* The data for this model. Here they are separated from the ones */
   /* retrieved from Carris API and from other community sources. */
   
   // From Carris API › Vehicle Summary
   public var routeNumber: String?
   
   public var lat: Double?
   public var lng: Double?
   public var previousLatitude: Double?
   public var previousLongitude: Double?
   public var lastGpsTime: String?
   
   public var coordinate: CLLocationCoordinate2D? {
      return CLLocationCoordinate2D(latitude: self.lat ?? 0, longitude: self.lng ?? 0)
   }
   
   public var previousCoordinate: CLLocationCoordinate2D? {
      return CLLocationCoordinate2D(latitude: self.previousLatitude ?? 0, longitude: self.previousLongitude ?? 0)
   }
   
   public var kind: Kind? {
      return Helpers.getKind(by: self.routeNumber ?? "")
   }
   
   public var angleInRadians: Double? {
      return self.getAngleInRadians(
         prevLat: previousLatitude ?? 0,
         prevLng: previousLongitude ?? 0,
         currLat: coordinate?.latitude ?? 0,
         currLng: coordinate?.longitude ?? 0
      )
   }
   
   // Carris API › Vehicle Details
   public var vehiclePlate: String?
   public var lastStopOnVoyageId: Int?
   public var lastStopOnVoyageName: String?
   
   // Community API
   public var estimatedTimeofArrivalCorrected: [String]?
   
   
   
   /* * */
   /* MARK: - SECTION 3: INITIALIZER */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia, */
   /* molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum */
   
//   public init(id: Int) {
//      self.id = id
//   }
//   
//   public init(id: Int, lat: Double, lng: Double, routeNumber: String) {
//      self.id = id
//      self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//      self.routeNumber = routeNumber
//   }
   
   
   
   /* * */
   /* MARK: - SECTION 3: INITIALIZER */
   /* Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia, */
   /* molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum */
   
   public func update() async {
      
      await updateVehicleWithAdditionalDetailsFromCarrisAPI()
      
   }
   
   
   
   
   /* * */
   /* MARK: - SECTION 4: FETCH VEHICLE DETAILS FROM CARRIS API */
   /* This function calls Carris SGO endpoint to retrieve additional vehicle info, */
   /* such as the license plate and final stop. This is the only way to retreive this */
   /* information. This function should only be called when the user requests it. */
   
   private func updateVehicleWithAdditionalDetailsFromCarrisAPI() async {
      
      Appstate.shared.change(to: .loading, for: .vehicles)
      
      do {
         
         // Request Vehicle Detail (SGO)
         var requestAPIVehicleDetail = URLRequest(url: URL(string: "\(CarrisAPISettings.endpoint)/SGO/busNumber/\(self.id)")!)
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Content-Type")
         requestAPIVehicleDetail.addValue("application/json", forHTTPHeaderField: "Accept")
         requestAPIVehicleDetail.setValue("Bearer \(CarrisAuthentication.shared.authToken ?? "invalid_token")", forHTTPHeaderField: "Authorization")
         let (rawDataAPIVehicleDetail, rawResponseAPIVehicleDetail) = try await URLSession.shared.data(for: requestAPIVehicleDetail)
         let responseAPIVehicleDetail = rawResponseAPIVehicleDetail as? HTTPURLResponse
         
         // Check status of response
         if (responseAPIVehicleDetail?.statusCode == 401) {
            await CarrisAuthentication.shared.authenticate()
            await self.updateVehicleWithAdditionalDetailsFromCarrisAPI()
            return
         } else if (responseAPIVehicleDetail?.statusCode != 200) {
            print(responseAPIVehicleDetail as Any)
            throw Appstate.ModuleError.carris_unavailable
         }
         
         let decodedAPIVehicleDetail = try JSONDecoder().decode(CarrisAPIVehicleDetail.self, from: rawDataAPIVehicleDetail)
         
         // Update properties with new values
         self.vehiclePlate = decodedAPIVehicleDetail.vehiclePlate
         self.lastStopOnVoyageId = decodedAPIVehicleDetail.lastStopOnVoyageId
         self.lastStopOnVoyageName = decodedAPIVehicleDetail.lastStopOnVoyageName
         self.lat = decodedAPIVehicleDetail.lat ?? 0
         self.lng = decodedAPIVehicleDetail.lng ?? 0
         
         Appstate.shared.change(to: .idle, for: .vehicles)
         
      } catch {
         Appstate.shared.change(to: .error, for: .vehicles)
         print("ERROR IN VEHICLE DETAILS: \(error)")
         return
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 4: CALCULATE VEHICLE ANGLE */
   /* Calculate the angle in radians from the last two locations to correctly point */
   /* the front of the vehicle to its current direction. */
   
   func getAngleInRadians(prevLat: Double, prevLng: Double, currLat: Double, currLng: Double) -> Double {
      // and return response to the caller
      let x = currLat - prevLat;
      let y = currLng - prevLng;
      
      var teta: Double;
      // Angle is calculated with the arctan of ( y / x )
      if (x == 0){ teta = .pi / 2 }
      else { teta = atan(y / x) }
      
      // If x is negative, then the angle is in the symetric quadrant
      if (x < 0) { teta += .pi }
      
      return teta - (.pi / 2) // Correction cuz Apple rotates clockwise
      
   }
   
}
