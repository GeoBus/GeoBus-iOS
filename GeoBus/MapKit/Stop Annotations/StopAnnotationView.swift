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
      
      canShowCallout = true
      //      calloutOffset = CGPoint(x: -5, y: 5)
      //      let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48)))
      //      mapsButton.setBackgroundImage(#imageLiteral(resourceName: "Map"), for: .normal)
      //      rightCalloutAccessoryView = mapsButton
      
//      image = StopAnnotationMarker(color: annotation.markerColor).asImage()
      
      frame = imageView.frame
      imageView.tintColor = annotation.markerColor
      addSubview(imageView)
      
      estimationsStorage.set(publicId: annotation.publicId, state: .idle)
      
      let child = UIHostingController(rootView: StopAnnotationCallout(estimationsStorage: self.estimationsStorage))
      child.view.backgroundColor = .clear
      detailCalloutAccessoryView = child.view
    
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
