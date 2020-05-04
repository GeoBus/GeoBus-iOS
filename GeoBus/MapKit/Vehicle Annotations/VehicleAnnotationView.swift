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
  
  var imageView = UIImageView(image: UIImage(named: "RegularService"))
  
  override var annotation: MKAnnotation? {
    
    willSet {
      guard let annotation = newValue as? VehicleAnnotation else {
        return
      }

      switch annotation.kind {
        case "tram":
          imageView.image = UIImage(named: "Tram")
          break
        case "neighborhood":
          imageView.image = UIImage(named: "RegularService")
          break
        case "night":
          imageView.image = UIImage(named: "RegularService")
          break
        case "elevator":
          imageView.image = UIImage(named: "RegularService")
          break
        default:
          imageView.image = UIImage(named: "RegularService")
          break
      }
      
      
      imageView.transform = CGAffineTransform(rotationAngle: CGFloat(annotation.angleInRadians))
      frame = imageView.frame
      addSubview(imageView)
      
      let callout = VehicleAnnotationCallout(annotation: annotation)
      let child = UIHostingController(rootView: callout)
      child.view.backgroundColor = .clear
      detailCalloutAccessoryView = child.view
      canShowCallout = true
    }
  }
}

