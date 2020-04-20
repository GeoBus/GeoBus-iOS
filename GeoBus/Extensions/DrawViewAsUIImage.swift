//
//  DrawViewAsUIImage.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import SwiftUI

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
