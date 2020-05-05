//
//  CustomMKAnnotationView.swift
//  GeoBus
//
//  Created by João on 18/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import MapKit

class StopAnnotationView: MKAnnotationView {
  
  var marker = UIImageView(image: UIImage(systemName: "arrow.clockwise.circle.fill"))
  
  override var annotation: MKAnnotation? {
    
    willSet {
      
      guard let annotation = newValue as? StopAnnotation else {
        return
      }
      
      canShowCallout = false
      
      marker.image = annotation.markerSymbol
      marker.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
      frame = marker.frame
      addSubview(marker)
      
    }
    
  }
  
}
