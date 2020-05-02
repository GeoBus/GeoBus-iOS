//
//  RouteSelectionHeaderView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SheetHeader: View {
  
  let title: Text
  @Binding var toggle: Bool
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button(action: { self.toggle = false }) {
          Text("Close")
            .fontWeight(.bold)
        }
        .padding(25)
        
      }
      title
        .font(.largeTitle)
        .fontWeight(.bold)
    }
    .padding(.bottom, 20)
  }
}
