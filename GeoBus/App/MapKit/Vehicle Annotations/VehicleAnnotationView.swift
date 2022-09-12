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
      
      marker.image = annotation.lastSeen <= 60 ? annotation.activeMarkerSymbol : annotation.stalledMarkerSymbol
      marker.alpha = annotation.lastSeen <= 60 ? 1 : 0.5
      
      marker.contentMode = .center
      marker.transform = CGAffineTransform(rotationAngle: CGFloat(annotation.angleInRadians))
      marker.frame = CGRect(origin: .zero, size: marker.image!.size)

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
