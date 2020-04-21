//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectRouteInput: View {
  
  @Binding var selectedRouteNumber: String
  @Binding var presentRouteSelectionSheet: Bool
  
  var body: some View {
    VStack {
      HStack {
        TextField("_ _ _", text: self.$selectedRouteNumber)
          .font(.system(size: 40, weight: .bold, design: .default))
          .multilineTextAlignment(.center)
          .padding()
          .background(Color(red: 0.9, green: 0.9, blue: 0.9))
          .cornerRadius(10)
          .frame(width: 120)
        
        Button(action: { self.presentRouteSelectionSheet = false }) {
          Text("Locate")
            .font(.system(size: 40, weight: .bold, design: .default))
            .foregroundColor(.white)
        }
        .disabled(selectedRouteNumber.count == 0)
        .frame(maxWidth: .infinity)
        .padding()
        .background(selectedRouteNumber.count > 2 ? Color.blue : Color.gray)
        .cornerRadius(10)
      }
      Text("Choose a Route Number (like 758 or 28E) to locate the buses on the map in real time.")
        .font(.footnote)
        .multilineTextAlignment(.center)
        .padding()
    }
  }
}
