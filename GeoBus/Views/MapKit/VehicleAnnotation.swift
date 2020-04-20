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
  let title: String?
  let subtitle: String?
  let coordinate: CLLocationCoordinate2D
  
  init(title: String?, subtitle: String?, latitude: Double, longitude: Double) {
    self.title = title
    self.subtitle = subtitle
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
