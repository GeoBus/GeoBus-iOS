//
//  LandmarkAnnotation.swift
//  SwiftUI-MapView
//
//  Created by Anand Nimje on 12/12/19.
//  Copyright © 2019 Anand. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

class VehicleAnnotation: NSObject, MKAnnotation {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  
  let busNumber: String
  let routeNumber: String
  var lastStopInRoute: String
  let lastSeen: Int
  let kind: Kind
  
  let coordinate: CLLocationCoordinate2D
  let angleInRadians: Double
  
  
  init(
    busNumber: String,
    routeNumber: String,
    lastStopInRoute: String,
    lastSeen: Int,
    kind: Kind,
    latitude: Double,
    longitude: Double,
    angleInRadians: Double
  ) {
    self.busNumber = busNumber
    self.routeNumber = routeNumber
    self.lastStopInRoute = lastStopInRoute
    self.lastSeen = lastSeen
    self.kind = kind
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.angleInRadians = angleInRadians
  }
  
  
  var title: String? {
    return ""
  }
  
  var subtitle: String? {
    return ""
  }
  
  
  var activeMarkerSymbol: UIImage  {
    switch kind {
      case .tram:
        return UIImage(named: "Tram-Active")!
      default:
        return UIImage(named: "RegularService-Active")!
    }
  }
  
  var stalledMarkerSymbol: UIImage  {
    switch kind {
      case .tram:
        return UIImage(named: "Tram-Stalled")!
      default:
        return UIImage(named: "RegularService-Stalled")!
    }
  }
  
}
