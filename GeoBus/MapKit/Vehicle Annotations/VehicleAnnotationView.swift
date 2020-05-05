//
//  CustomMKAnnotationView.swift
//  GeoBus
//
//  Created by João on 18/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import MapKit

class VehicleAnnotationView: MKAnnotationView {
  
  var marker = UIImageView(image: UIImage(named: "RegularService"))
  
  override var annotation: MKAnnotation? {
    
    willSet {
      guard let annotation = newValue as? VehicleAnnotation else {
        return
      }
      
      marker.image = annotation.markerSymbol
      marker.transform = CGAffineTransform(rotationAngle: CGFloat(annotation.angleInRadians))
      frame = marker.frame
      addSubview(marker)
      
      let callout = VehicleAnnotationCallout(annotation: annotation)
      let child = UIHostingController(rootView: callout)
      child.view.backgroundColor = .clear
      detailCalloutAccessoryView = child.view
      canShowCallout = true
      
    }
    
  }
  
}

