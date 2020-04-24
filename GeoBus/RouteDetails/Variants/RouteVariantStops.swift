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
          Text("to: \(routesStorage.getTerminalStopNameForSelectedVariant(direction: .ascending))").tag(0)
          Text("to: \(routesStorage.getTerminalStopNameForSelectedVariant(direction: .descending))").tag(1)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.bottom, 20)
        
        VStack {
          ForEach(getStopsToShow(for: self.routeDirection)) { stop in
            VStack(alignment: .leading) {
              StopDetails(stop: stop)
                .padding(.bottom)
            }
            .padding(.horizontal)
          }
        }
        
      } else {
        
        RouteCircularVariantInfo()
        
        VStack {
          ForEach(self.routesStorage.selectedVariant!.circular) { stop in
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
  
  
  func getStopsToShow(for direction: Int) -> [Stop] {
    switch routeDirection {
      case 0: return self.routesStorage.selectedVariant!.ascending
      case 1: return self.routesStorage.selectedVariant!.descending
      default: return self.routesStorage.selectedVariant!.circular
    }
  }
  
}
