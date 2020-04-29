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
      
      let detailLabel = UILabel()
      detailLabel.numberOfLines = 0
      detailLabel.font = detailLabel.font.withSize(12)
      detailLabel.text = annotation.subtitle
      detailCalloutAccessoryView = detailLabel
    
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








//struct StopAnnotationView: View {
//
//  var orderInRoute: String
//
//  var descending: Bool = false
//
//
//  var body: some View {
//    VStack {
//      Text(orderInRoute)
//        .font(.footnote)
//        .fontWeight(.bold)
//        .foregroundColor(.white)
//    }
//    .padding(.all, 5)
//    .background(descending ? Color(.systemBlue) : Color(.systemGreen))
//    .cornerRadius(.infinity)
//  }
//}






//struct CustomMKAnnotationView_Previews: PreviewProvider {
//  static var previews: some View {
//    CustomMKAnnotationView()
//  }
//}











// MARK: - Alternative Style
//


// LARGE LAYOUT

//var body: some View {
//  VStack(alignment: .leading) {
//    HStack {
//      Text("758")
//        .font(.footnote)
//        .fontWeight(.heavy)
//        .padding(.horizontal, 7)
//        .padding(.vertical, 2)
//        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.yellow))
//
//      Text("to")
//        .font(.caption)
//        .fontWeight(.medium)
//        .foregroundColor(.white)
//    }
//    Text("Escola Padre Cruz EB 23 - Lado esquerdo")
//      .font(.footnote)
//      .fontWeight(.bold)
//      .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//      .foregroundColor(.white)
//  }
//  .frame(maxWidth: 150, maxHeight: 50)
//  .padding(.horizontal, 5)
//  .padding(.vertical, 0)
//  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
//}






// MEDIUM LAYOUT

//var body: some View {
//  HStack {
//    Text(annotation.title!.prefix(3))
//      .font(.footnote)
//      .fontWeight(.heavy)
//      .padding(.horizontal, 7)
//      .padding(.vertical, 2)
//      .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.yellow))
//      .padding(.trailing, 0)
//
//    Text( (annotation.subtitle!.count > 20) ? annotation.subtitle!.prefix(17) + "..." : annotation.subtitle! )
//      .font(.footnote)
//      .fontWeight(.bold)
//      .multilineTextAlignment(.leading)
//      .allowsTightening(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
//      .foregroundColor(.white)
//      .padding(.leading, -5)
//  }
//  .padding(.leading, 0)
//  .padding(.trailing, 8)
//  .padding(.vertical, 0)
//  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.green))
//}
