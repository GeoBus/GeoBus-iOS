//
//  SelectRouteSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteSheet: View {

   @Environment(\.colorScheme) var colorScheme: ColorScheme

   @EnvironmentObject var routesController: RoutesController

   @Binding var showSelectRouteSheet: Bool


   var body: some View {

      ScrollView(.vertical, showsIndicators: true) {
         
         VStack {

            SheetHeader(title: Text("Find Routes"), toggle: $showSelectRouteSheet)

            SelectRouteInput(showSelectRouteSheet: self.$showSelectRouteSheet)
               .padding(.horizontal)

            Divider()

            VStack {
               FavoriteRoutes(showSelectRouteSheet: $showSelectRouteSheet)
               SetOfRoutes(title: Text("Trams"), kind: .tram, showSelectRouteSheet: $showSelectRouteSheet)
               SetOfRoutes(title: Text("Neighborhood Buses"), kind: .neighborhood, showSelectRouteSheet: $showSelectRouteSheet)
               SetOfRoutes(title: Text("Night Buses"), kind: .night, showSelectRouteSheet: $showSelectRouteSheet)
               SetOfRoutes(title: Text("Regular Service"), kind: .regular, showSelectRouteSheet: $showSelectRouteSheet)
            }

            About()

         }

      }
      .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
      .edgesIgnoringSafeArea(.bottom)

   }


}


