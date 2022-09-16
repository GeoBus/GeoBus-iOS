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

   @Binding var isPresentingSheet: Bool


   var body: some View {

      ScrollView(.vertical, showsIndicators: true) {
         
         VStack {

            SheetHeader(title: Text("Find Routes"), toggle: $isPresentingSheet)

            SelectRouteInput(showSheet: $isPresentingSheet)
               .padding(.horizontal)

            Divider()

            VStack {
               FavoriteRoutes(showSelectRouteSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Trams"), kind: .tram, showSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Neighborhood Buses"), kind: .neighborhood, showSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Night Buses"), kind: .night, showSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Regular Service"), kind: .regular, showSheet: $isPresentingSheet)
            }

            About()

         }

      }
      .background(colorScheme == .dark ? Color(.systemBackground) : Color(.secondarySystemBackground))
      .edgesIgnoringSafeArea(.bottom)

   }


}


