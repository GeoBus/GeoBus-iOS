//
//  RouteVariantStops.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct RouteVariantStops: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  
  @State var routeDirection: Int = 0
  
  var body: some View {
    
    VStack {
      
      if !(routesStorage.selectedVariant?.isCircular ?? true) {
        
        Picker("Direction", selection: $routeDirection) {
          Text("Ascending").tag(0)
          Text("Descending").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.bottom, 20)
        
      } else {
        
        RouteCircularVariantInfo()
        
      }
      
      VStack {
        ForEach(routesStorage.selectedVariant!.ascending) { stop in
          VStack(alignment: .leading) {
            StopDetails(stop: stop)
              .padding(.bottom)
          }
          .padding(.horizontal)
        }
      }
      
    }
  }
}
