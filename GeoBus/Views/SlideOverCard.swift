//
//  SlideOverCard.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SlideOverCard<Content: View> : View {
  @GestureState private var dragState = DragState.inactive
  @State var position: CGFloat = 50
  let enabledPosition: CGFloat = 50
  
  var content: () -> Content
  
  var body: some View {
    let drag = DragGesture()
      .updating($dragState) { drag, state, _ in
        state = .dragging(translation: drag.translation)
    }
    .onEnded(onDragEnded)
    
    return VStack {
      Handle().zIndex(999)
      self.content()
      // CardContentsView(vehicleStore: VehicleStore())
    }
    .frame(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height - enabledPosition
    )
      .background(Color.white)
      .cornerRadius(20.0)
      .shadow(
        color: Color(.sRGBLinear, white: 0, opacity: 0.15),
        radius: 20.0
    )
      .offset(y: self.position + self.dragState.translation.height)
      .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
      .gesture(drag)
  }
  
  private func onDragEnded(drag: DragGesture.Value) {
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    let disabledPosition: CGFloat = screenHeight - 150
    let verticalDirection = drag.predictedEndLocation.y - drag.location.y
    
    if verticalDirection > 0 {
      self.position = disabledPosition
    } else {
      self.position = enabledPosition
    }
  }
}

enum DragState {
  case inactive
  case dragging(translation: CGSize)
  
  var translation: CGSize {
    switch self {
      case .inactive:
        return .zero
      case .dragging(let translation):
        return translation
    }
  }
  
  var isDragging: Bool {
    switch self {
      case .inactive:
        return false
      case .dragging:
        return true
    }
  }
}
