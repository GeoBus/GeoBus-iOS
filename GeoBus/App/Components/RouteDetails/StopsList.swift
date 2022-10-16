//
//  RouteVariantStops.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct StopsList: View {

   @State var stops: [Stop] = []


   var body: some View {
      VStack(alignment: .leading, spacing: 15) {
         ForEach(stops) { stop in
            ConnectionDetailsView2(
               canToggle: true,
               publicId: stop.publicId,
               name: stop.name,
               orderInRoute: stop.orderInRoute,
               direction: stop.direction
            )
         }
      }
   }

}
