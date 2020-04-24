//
//  RouteSelectionTextFieldAndButtonView.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct SelectRouteInput: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @Binding var presentRouteSelectionSheet: Bool
  
  @State var routeNumber = ""
  
  
  var body: some View {
    VStack {
      HStack {
        TextField("_ _ _", text: self.$routeNumber)
          .font(.system(size: 40, weight: .bold, design: .default))
          .multilineTextAlignment(.center)
          .padding()
          .background(Color(.secondarySystemBackground))
          .cornerRadius(10)
          .frame(width: 120)
        
        Button(action: {
          self.routesStorage.select(with: self.routeNumber)
          self.presentRouteSelectionSheet = false
        }) {
          Text("Locate")
            .font(.system(size: 40, weight: .bold, design: .default))
            .foregroundColor(Color(.label))
        }
        .disabled(routeNumber.count == 0)
        .frame(maxWidth: .infinity)
        .padding()
        .background(routeNumber.count > 2 ? Color(.systemBlue) : Color(.secondarySystemBackground))
        .cornerRadius(10)
      }
      Text("Choose a Route Number (like 758 or 28E) to locate the buses on the map in real time.")
        .font(.footnote)
        .multilineTextAlignment(.center)
        .padding()
    }
  }
}
