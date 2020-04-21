//
//  HorizontalLine.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct VerticalLine: View {
  
  let thickness: CGFloat
  var color: Color
  
  init() {
    self.thickness = 1
    self.color = Color(red: 0.95, green: 0.95, blue: 0.95)
  }
  
  init(thickness: CGFloat, color: Color) {
    self.thickness = thickness
    self.color = color
  }
  
  init(thickness: CGFloat) {
    self.thickness = thickness
    self.color = Color(red: 0.95, green: 0.95, blue: 0.95)
  }
  
  init(color: Color) {
    self.thickness = 1
    self.color = color
  }
  
  var body: some View {
    Rectangle()
      .frame(width: thickness)
      .foregroundColor(color)
  }
}
