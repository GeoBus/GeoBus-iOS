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
  
  let routeNumber: String?
  let lastStopInRoute: String?
  
  let coordinate: CLLocationCoordinate2D
  
  
  init(routeNumber: String?, lastStopInRoute: String?, latitude: Double, longitude: Double) {
    self.routeNumber = routeNumber
    self.lastStopInRoute = lastStopInRoute
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  
  var title: String? {
    return routeNumber
  }
  
  var subtitle: String? {
    return lastStopInRoute
  }
  
}
