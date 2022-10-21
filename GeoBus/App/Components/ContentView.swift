//
//  ContentView.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct ContentView: View {
   
   var body: some View {
      VStack(spacing: 0) {
         
         ZStack(alignment: .topTrailing) {
            MapView()
               .edgesIgnoringSafeArea(.vertical)
            VStack(spacing: 15) {
               AboutGeoBus()
               Spacer()
               StopSearch()
               UserLocation()
            }
            .padding()
         }
         
         NavBar()
            .edgesIgnoringSafeArea(.vertical)
         
      }
   }
   
}
