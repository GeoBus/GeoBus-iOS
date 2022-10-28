//
//  SelectRouteSheet.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteSheet: View {

   
   var body: some View {

      ScrollView(showsIndicators: true) {
         
         VStack(spacing: 30) {

            SheetHeader(title: Text("Find Routes"))

            SelectRouteInput()
               .padding(.horizontal)

            Divider()

            VStack(spacing: 30) {
               FavoriteRoutes()
               SetOfRoutes(title: Text("Trams"), kind: .tram)
               SetOfRoutes(title: Text("Neighborhood Buses"), kind: .neighborhood)
               SetOfRoutes(title: Text("Night Buses"), kind: .night)
               SetOfRoutes(title: Text("Regular Service"), kind: .regular)
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


