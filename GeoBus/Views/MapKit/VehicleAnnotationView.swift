//
//  CustomMKAnnotationView.swift
//  GeoBus
//
//  Created by João on 18/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI
import MapKit

struct VehicleAnnotationView: View {
  
  let title: String
  
  var body: some View {
    Text(title.prefix(3))
      .font(.footnote)
      .fontWeight(.heavy)
      .padding(.horizontal, 7)
      .padding(.vertical, 2)
      .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.yellow))
      .padding(.trailing, 0)
  }
}


extension View {
  func asImage() -> UIImage {
    let controller = UIHostingController(rootView: self)
    
    // locate far out of screen
    controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
    UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
    
    let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
    controller.view.bounds = CGRect(origin: .zero, size: size)
    controller.view.sizeToFit()
    
    let image = controller.view.asImage()
    controller.view.removeFromSuperview()
    return image
  }
}

extension UIView {
  func asImage() -> UIImage {
    let rendererFormat = UIGraphicsImageRendererFormat()
    rendererFormat.opaque = false
    let renderer = UIGraphicsImageRenderer(bounds: bounds, format: rendererFormat)
    return renderer.image { rendererContext in
      // [!!] Uncomment to clip resulting image
      rendererContext.cgContext.addPath(
        UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath)
      rendererContext.cgContext.clip()
      layer.render(in: rendererContext.cgContext)
    }
  }
}



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
