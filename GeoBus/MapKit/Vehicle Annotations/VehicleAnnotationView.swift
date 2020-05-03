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
  
  let imageView = UIImageView(image: UIImage(named: "RegularService"))
  
  override var annotation: MKAnnotation? {
    
    willSet {
      guard let annotation = newValue as? VehicleAnnotation else {
        return
      }
      
      canShowCallout = true
      //      calloutOffset = CGPoint(x: -5, y: 5)
      //      let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48)))
      //      mapsButton.setBackgroundImage(#imageLiteral(resourceName: "Map"), for: .normal)
      //      rightCalloutAccessoryView = mapsButton
      
      imageView.transform = CGAffineTransform(rotationAngle: CGFloat(annotation.angleInRadians))
      frame = imageView.frame
      addSubview(imageView)
      
      let callout = VehicleAnnotationCallout(annotation: annotation)
      let child = UIHostingController(rootView: callout)
      child.view.backgroundColor = .clear
      detailCalloutAccessoryView = child.view
    }
  }
}

