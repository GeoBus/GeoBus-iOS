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
  @State var showErrorLabel: Bool = false
  
  
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
          let success = self.routesStorage.select(with: self.routeNumber)
          if success {
            self.presentRouteSelectionSheet = false
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
      
      if showErrorLabel {
        Text("The route you entered does not exist.")
          .font(.footnote)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
          .foregroundColor(Color(.systemOrange))
          .padding()
      }
      
      Text("Choose a Route Number (ex: 28E or 758).")
        .font(.footnote)
        .multilineTextAlignment(.center)
        .padding()
    }
  }
}
