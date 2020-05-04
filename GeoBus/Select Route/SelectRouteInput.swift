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
  
  @Binding var showSelectRouteSheet: Bool
  
  @State var showErrorLabel: Bool = false
  
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
          let success = self.routesStorage.select(with: self.routeNumber.uppercased())
          if success {
            self.showSelectRouteSheet = false
          } else {
            self.showErrorLabel = true
          }
        }) {
          Text("Locate")
            .font(.system(size: 40, weight: .bold, design: .default))
            .foregroundColor(routeNumber.count > 2 ? Color(.white) : Color(.secondaryLabel))
        }
        .disabled(routeNumber.count == 0)
        .frame(maxWidth: .infinity)
        .padding()
        .background(routeNumber.count > 2 ? Color(.systemBlue) : Color(.secondarySystemBackground))
        .cornerRadius(10)
      }
      
      if showErrorLabel && routeNumber.count > 0 {
        Text("The route you entered does not exist.")
          .font(.body)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
          .foregroundColor(Color(.systemOrange))
          .padding()
      }
      
      Text("Choose a Route Number (ex: 28E or 758).")
        .font(.body)
        .multilineTextAlignment(.center)
        .padding()
    }
  }
}
