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
  
  let imageView = UIImageView(image: UIImage(systemName: "circle.fill"))
  
  @ObservedObject var estimationsStorage = EstimationsStorage()
  
  override var annotation: MKAnnotation? {
    
    willSet {
      
      guard let annotation = newValue as? StopAnnotation else {
        return
      }
      
      canShowCallout = false
      
      frame = imageView.frame
      imageView.tintColor = annotation.markerColor
      addSubview(imageView)
      
//      let child = UIHostingController(rootView: StopAnnotationCallout(estimationsStorage: estimationsStorage))
//      child.view.backgroundColor = .clear
//      detailCalloutAccessoryView = child.view
//      detailCalloutAccessoryView?.translatesAutoresizingMaskIntoConstraints = true
      
    }
    
  }
  
}



struct StopAnnotationMarker: View {
  
  let color: UIColor
  
  var body: some View {
    Circle()
      .frame(width: 8, height: 8)
      .foregroundColor(Color(color))
  }
  
}
