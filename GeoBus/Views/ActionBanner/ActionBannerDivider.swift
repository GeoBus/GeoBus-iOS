//
//  Handle.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 14/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct ActionBannerDivider: View {
  
  private let thickness: CGFloat = 2
  private let lineColor: Color = Color(red: 0.9, green: 0.9, blue: 0.9)
  
  var body: some View {
    Rectangle() //(cornerRadius: thickness / 2.0)
      .frame(width: thickness)
      .foregroundColor(lineColor)
//      .padding(5)
  }
}
