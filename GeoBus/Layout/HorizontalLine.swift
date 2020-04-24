//
//  HorizontalLine.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct HorizontalLine: View {
  
  let thickness: CGFloat
  
  init() {
    self.thickness = 1
  }
  
  init(thickness: CGFloat) {
    self.thickness = thickness
  }

  var body: some View {
    Rectangle()
      .frame(height: thickness)
      .foregroundColor(Color(.separator))
  }
}
