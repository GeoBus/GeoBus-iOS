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
  
  let routeNumber: String
  let lastStopInRoute: String
  
  let busNumber: String
  
  let coordinate: CLLocationCoordinate2D
  let angleInRadians: Double
  
  
  init(routeNumber: String, lastStopInRoute: String, busNumber: String, latitude: Double, longitude: Double, angleInRadians: Double) {
    self.routeNumber = routeNumber
    self.lastStopInRoute = lastStopInRoute
    self.busNumber = busNumber
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    self.angleInRadians = angleInRadians - (.pi / 2) // Correction cuz Apple rotates clockwise
  }
  
  
  var title: String? {
    return "" //\(routeNumber) to \(lastStopInRoute)
  }
  
  var subtitle: String? {
    return "#\(busNumber)"
  }
  
}
