//
//  LottieView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  var name: String!
  var loopMode: LottieLoopMode
  @Binding var play: Bool
  
  var animationView = AnimationView()
  
  class Coordinator: NSObject {
    var parent: LottieView
    
    init(_ animationView: LottieView) {
      self.parent = animationView
      super.init()
    }
  }
  
  func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
    let view = UIView()
    
    animationView.animation = Animation.named(name)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = loopMode.self
    
    animationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(animationView)
    
    NSLayoutConstraint.activate([
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
    ])
    
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
    animationView.play()
  }
}
