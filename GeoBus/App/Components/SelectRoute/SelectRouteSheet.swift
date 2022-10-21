//
//  SelectRouteSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteSheet: View {

   @Binding var isPresentingSheet: Bool


   var body: some View {

      ScrollView(.vertical, showsIndicators: true) {
         
         VStack(spacing: 30) {

            SheetHeader(title: Text("Find Routes"), toggle: $isPresentingSheet)

            SelectRouteInput(showSheet: $isPresentingSheet)
               .padding(.horizontal)

            Divider()

            VStack(spacing: 30) {
               FavoriteRoutes(showSelectRouteSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Trams"), kind: .tram, showSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Neighborhood Buses"), kind: .neighborhood, showSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Night Buses"), kind: .night, showSheet: $isPresentingSheet)
               SetOfRoutes(title: Text("Regular Service"), kind: .regular, showSheet: $isPresentingSheet)
            }
            .padding(.horizontal)

            Divider()

            VStack(spacing: 30) {
               ContactsCard()
               AppVersion()
            }
            .padding(.horizontal)

         }
         .padding(.bottom, 30)

      }
      .background(Color("BackgroundPrimary"))

   }


}


