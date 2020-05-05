//
//  LandmarkAnnotation.swift
//  SwiftUI-MapView
//
//  Created by Anand Nimje on 12/12/19.
//  Copyright © 2019 Anand. All rights reserved.
//

import MapKit

class StopAnnotation: NSObject, MKAnnotation {
  
  let name: String
  let publicId: String
  
  let direction: Route.Direction // To choose the color of the stop
  let orderInRoute: Int
  let lastStopOnVoyage: String
  
  let coordinate: CLLocationCoordinate2D
  
  
  init(name: String?, publicId: String?, direction: Route.Direction, orderInRoute: Int, lastStopOnVoyage: String, latitude: Double, longitude: Double) {
    self.name = name ?? "-"
    self.publicId = publicId ?? "-"
    self.direction = direction
    self.orderInRoute = orderInRoute
    self.lastStopOnVoyage = lastStopOnVoyage
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
    switch direction {
      case .ascending:
        return UIImage(named: "PinkArrowUp")!
      case .descending:
        return UIImage(named: "OrangeArrowDown")!
      case .circular:
        return UIImage(named: "OrangeArrowDown")!
    }
  }
  
}

