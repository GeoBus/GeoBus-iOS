//
//  RouteVariantPicker.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteVariantPicker: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  var body: some View {
    
    return ScrollView(.horizontal, showsIndicators: true) {
      
      HStack {
        
        RouteVariantWarning(qty: routesStorage.selectedRoute?.variants.count ?? 0)
        
        ForEach(routesStorage.selectedRoute!.variants) { variant in
          
          Button(action: {
            self.routesStorage.select(variant: variant)
          }) {
            RouteVariantButton(
              variantName: self.routesStorage.getVariantName(variant: variant),
              isSelected: self.routesStorage.isSelected(variant: variant)
            )
          }
        .disabled(self.routesStorage.isSelected(variant: variant))
        }
        
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom)
      .padding(.horizontal)
      
    }
  }
}






//VStack {
//  ForEach(stopsStorage.stops) { stop in
//    VStack(alignment: .leading) {
//      StopButton(stop: stop)
//        .padding(.bottom)
//      //              VerticalLine(thickness: 2, color: .yellow)
//    }
//    .padding(.horizontal)
//  }
//}
