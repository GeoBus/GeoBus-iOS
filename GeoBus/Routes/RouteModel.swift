//
//  RouteModel.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 09/09/2022.
//  Copyright © 2022 João de Vasconcelos. All rights reserved.
//

import Foundation
import MapKit

enum RouteKind: Codable, Equatable {
   case neighborhood
   case elevator
   case tram
   case night
   case regular
}

enum RouteVariantDirection: Codable {
   case ascending
   case descending
   case circular
}

struct RouteFinal: Codable, Equatable, Identifiable {
   let number: String
   let name: String
   let kind: RouteKind
   let variants: [RouteVariantFinal]

   var id: String {
      return self.number
   }
}

struct RouteVariantFinal: Codable, Equatable, Identifiable {
   let number: Int
   let isCircular: Bool
   var upItinerary, downItinerary, circItinerary: [RouteVariantStopFinal]?

   var id: String {
      return String(describing: self.number)
   }
}


struct RouteVariantStopFinal: Codable, Equatable, Identifiable {
   let orderInRoute: Int
   let publicId: String
   let name: String
   let direction: RouteVariantDirection
   let lastStopOnVoyage: String
   let lat, lng: Double

   var id: String {
      return self.publicId
   }

}



class RouteVariantStopAnnotation: NSObject, MKAnnotation {

   let originalStop: RouteVariantStopFinal

   let coordinate: CLLocationCoordinate2D


   init(originalStop: RouteVariantStopFinal, latitude: Double, longitude: Double) {
      self.originalStop = originalStop
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      super.init()
   }


   var title: String? {
      return ""
   }

   var subtitle: String? {
      return ""
   }


   var markerSymbol: UIImage  {
      switch originalStop.direction {
         case .ascending:
            return UIImage(named: "PinkArrowUp")!
         case .descending:
            return UIImage(named: "OrangeArrowDown")!
         case .circular:
            return UIImage(named: "BlueArrowRight")!
      }
   }

}
