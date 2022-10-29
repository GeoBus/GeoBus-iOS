import Foundation

/* * */
/* MARK: - CARRIS COMMUNITY API DATA MODEL */
/* Data model as provided by Community API for Carris network. */
/* Schema is available at https://github.com/ricardojorgerm/carril */

struct CarrisCommunityAPIModel {
   
   struct Vehicle: Decodable {
      // let busNumber: Int?
      // let dataServico: String?
      // let direction: String?
      // let enrichedAvgRouteSpeed: Double?
      // let enrichedBusSpeed: Double?
      // let enrichedDbStartup: Double?
      // let enrichedEstRouteKm: Double?
      // let enrichedGeohash300m: String?
      // let enrichedGeohash80m: String?
      // let enrichedGeohashPrev300m: String?
      // let enrichedGeohashPrev80m: String?
      // let enrichedPreviousStopId: String?
      // let enrichedPreviousStopList: [String]?
      // let enrichedPreviousStopMax: Int?
      // let enrichedPreviousStopOrderIdx: Double?
      // let enrichedQueryTime: Double?
      // let enrichedRouteCoords: [Double]?
      // let enrichedRouteDirection: Double?
      // let enrichedRouteDoneKm: Double?
      // let enrichedRouteLengthKm: Double?
      // let enrichedSequenceNo: Int?
      // let enrichedStartLat: Double?
      // let enrichedStartLng: Double?
      // let enrichedStartTime: String?
      // let enrichedTimeHash30m: String?
      // let enrichedTimeHashDay30m: String?
      // let estimatedDebug: [String]?
      // let estimatedRouteItinerary: [String]?
      let estimatedRouteResults: [EstimatedRouteResult]?
      // let lastGpsTime: String?
      // let lastReportTime: String?
      // let lat: Double?
      // let lng: Double?
      // let plateNumber: String?
      // let previousLatitude: Double?
      // let previousLongitude: Double?
      // let previousReportTime: String?
      // let routeNumber: String?
      // let state: String?
      // let timeStamp: String?
      // let variantNumber: Int?
      // let voyageNumber: Int?
   }
   
   struct EstimatedRouteResult: Decodable {
      // let estimatedFeatures: [EstimatedFeature]?
      let estimatedPreviouslyArrived: Bool?
      // let estimatedRecentlyArrived: Bool?
      let estimatedRouteStopId: String?
      // let estimatedRouteStopPosition: Double?
      // let estimatedTimeofArrival: String?
      let estimatedTimeofArrivalCorrected: String?
      // let estimatedUncertainty: String?
   }
   
   
   
   struct Estimation: Decodable {
      let busNumber: Int?
      // let dataServico: String?
      let direction: String?
      // let enrichedAvgRouteSpeed: Double?
      // let enrichedBusSpeed: Double?
      // let enrichedDbStartup: Double?
      // let enrichedEstRouteKm: Double?
      // let enrichedGeohash300m: String?
      // let enrichedGeohash80m: String?
      // let enrichedGeohashPrev300m: String?
      // let enrichedGeohashPrev80m: String?
      // let enrichedPreviousStopId: String?
      // let enrichedPreviousStopList: [String]?
      // let enrichedPreviousStopMax: Int?
      // let enrichedPreviousStopOrderIdx: Double?
      // let enrichedQueryTime: Double?
      // let enrichedRouteCoords: [Double]?
      // let enrichedRouteDirection: Double?
      // let enrichedRouteDoneKm: Double?
      // let enrichedRouteLengthKm: Double?
      // let enrichedSequenceNo: Int?
      // let enrichedStartLat: Double?
      // let enrichedStartLng: Double?
      // let enrichedStartTime: String?
      // let enrichedTimeHash30m: String?
      // let enrichedTimeHashDay30m: String?
      // let estimatedDebug: [String]?
      // let estimatedFeatures: EstimatedFeature?
      // let estimatedPreviouslyArrived: Bool?
      // let estimatedRecentlyArrived: Bool?
      // let estimatedRouteStopId: String?
      // let estimatedRouteStopPosition: Double?
      // let estimatedTimeofArrival: String?
      let estimatedTimeofArrivalCorrected: String?
      // let estimatedUncertainty: String?
      // let lastGpsTime: String?
      // let lastReportTime: String?
      // let lat: Double?
      // let lng: Double?
      // let plateNumber: String?
      // let previousLatitude: Double?
      // let previousLongitude: Double?
      // let previousReportTime: String?
      let routeNumber: String?
      // let state: String?
      // let timeStamp: String?
      let variantNumber: Int?
      // let voyageNumber: Int?
   }
   
   
   
   struct EstimatedFeature: Decodable {
      // let avgHistorDeltaDistanceKm: Double?
      // let avgHistorDeltaSeconds: Double?
      // let avgHistorDeltaSeqNo: Double?
      // let avgHistorInstSpeedAtPositionKmh: Double?
      // let avgHistorLongtermSpeedAtPositionKmh: Double?
      // let correctionFactorLongTerm: Double?
      // let correctionFactorShortTerm: Double?
      // let maxHistorDelta: Int?
      // let minHistorDelta: Int?
      // let noHistorSamples: Int?
      // let stdHistorDeltaSeconds: Double?
   }
   
}
