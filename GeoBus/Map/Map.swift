//
//  Map.swift
//  GeoBus
//
//  Created by João on 02/05/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct Map: View {
  
  @ObservedObject var routesStorage: RoutesStorage
  @ObservedObject var vehiclesStorage: VehiclesStorage

  
  var body: some View {
    
    ZStack(alignment: .top) {
      
      MapView(routesStorage: routesStorage, vehiclesStorage: vehiclesStorage)
        .edgesIgnoringSafeArea(.vertical)
        .padding(.bottom, -10)
      
      if routesStorage.isStopSelected {
        AnnotationBanner(selectedStopAnnotation: routesStorage.selectedStopAnnotation)
      }
      
    }
    
  }
  
}
