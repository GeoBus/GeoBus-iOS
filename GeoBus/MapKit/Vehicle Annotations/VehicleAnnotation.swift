//
//  LandmarkAnnotation.swift
//  SwiftUI-MapView
//
//  Created by Anand Nimje on 12/12/19.
//  Copyright © 2019 Anand. All rights reserved.
//

import Foundation
import MapKit

class VehicleAnnotation: NSObject, MKAnnotation {
  
  let busNumber: String
  let routeNumber: String
  let lastStopInRoute: String
  let lastGpsTime: String
  let kind: String
  
  let coordinate: CLLocationCoordinate2D
  let angleInRadians: Double
  
  
  init(
    busNumber: String,
    routeNumber: String,
    lastStopInRoute: String,
    lastGpsTime: String,
    kind: String,
    latitude: Double,
    longitude: Double,
    angleInRadians: Double
  ) {
    self.busNumber = busNumber
    self.routeNumber = routeNumber
    self.lastStopInRoute = lastStopInRoute
    self.lastGpsTime = lastGpsTime
    self.kind = kind
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.angleInRadians = angleInRadians - (.pi / 2) // Correction cuz Apple rotates clockwise
  }
  
  
  var title: String? {
    return ""
  }
  
  var subtitle: String? {
    return ""
  }
  
  
  var markerSymbol: UIImage  {
    switch kind {
      case "tram":
        return UIImage(named: "Tram")!
      case "neighborhood":
        return UIImage(named: "RegularService")!
      case "night":
        return UIImage(named: "RegularService")!
      case "elevator":
        return UIImage(named: "RegularService")!
      default:
        return UIImage(named: "RegularService")!

    }
  }
  
}
