//
//  SelectRouteView.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct SelectRouteView: View {
   
   @Environment(\.colorScheme) var colorScheme: ColorScheme
   
   @ObservedObject private var appstate = Appstate.shared
   @ObservedObject private var carrisNetworkController = CarrisNetworkController.shared
   
   
   var body: some View {
      
      ZStack {
         
         if (appstate.global == .loading) {
            ZStack {
               RoundedRectangle(cornerRadius: 10)
                  .fill(Color(.systemGray4))
               Spinner()
            }
            
         } else if (appstate.global == .error) {
            RoundedRectangle(cornerRadius: 10)
               .fill(Color(.systemRed).opacity(0.5))
            Image(systemName: "wifi.exclamationmark")
               .font(.title)
               .foregroundColor(Color(.white))
            
         } else {
            
            if (carrisNetworkController.activeRoute != nil) {
               RouteBadgeSquare(routeNumber: carrisNetworkController.activeRoute!.number)
               
            } else {
               RoundedRectangle(cornerRadius: 10)
                  .fill(Color(.systemGray4))
               Image(systemName: "plus")
                  .font(.title)
                  .foregroundColor(Color(.white))
               
            }
            
         }
         
      }
      .aspectRatio(1, contentMode: .fit)
      
   }
}
