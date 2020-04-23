//
//  RouteDetailsOverview.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteDetailsVehiclesQuantity: View {
  
  var vehiclesQuantity: Int
  
  var body: some View {
    ZStack(alignment: .topLeading) {
      
      LiveIcon()
      
      VStack(alignment: .center) {
        Text(String(vehiclesQuantity))
          .font(.system(size: 30, weight: .bold, design: .default))
          .padding(.bottom, 5)
        Text("\(vehiclesQuantity == 1 ? "vehicle" : "vehicles" ) in circulation")
          .multilineTextAlignment(.center)
          .font(.callout)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
    .cornerRadius(10)
    
  }
}
