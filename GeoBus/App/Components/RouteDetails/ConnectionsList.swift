//
//  RouteVariantStops.swift
//  GeoBus
//
//  Created by João on 23/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct ConnectionsList: View {

   let connections: [CarrisNetworkModel.Connection]


   var body: some View {
      VStack(alignment: .leading, spacing: 15) {
         ForEach(connections) { connection in
            ConnectionDetailsView2(
               canToggle: true,
               publicId: connection.stop.publicId,
               name: connection.stop.name,
               orderInRoute: connection.orderInRoute,
               direction: connection.direction
            )
         }
      }
   }

}
