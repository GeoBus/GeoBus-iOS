//
//  RouteBadgePill.swift
//  GeoBus
//
//  Created by João on 29/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct VehicleIdentifier: View {

   let busNumber: Int?
   let vehiclePlate: String?

   @State var toggleIdentifier: Bool = false

   @State var placeholderOpacity: Double = 1
   
   var placeholder: some View {
      Text("00000")
         .font(Font.system(size: 12, weight: .bold, design: .monospaced) )
         .foregroundColor(.clear)
         .padding(.vertical, 2)
         .padding(.horizontal, 7)
         .background(Color("PlaceholderShape"))
         .cornerRadius(5)
         .opacity(placeholderOpacity)
         .animatePlaceholder(binding: $placeholderOpacity)
   }
   
   

   var busNumberView: some View {
      Text(String(busNumber!))
         .font(Font.system(size: 12, weight: .bold, design: .monospaced) )
         .foregroundColor(.primary)
         .padding(.vertical, 2)
         .padding(.horizontal, 7)
         .background(Color(.secondarySystemFill))
         .cornerRadius(5)
   }


   var licensePlateView: some View {
      HStack(spacing: 0) {
         ZStack {
            Text(verbatim: "P")
               .font(.system(size: 8, weight: .bold, design: .monospaced))
               .foregroundColor(.white)
               .padding(.horizontal, 3)
               .padding(.vertical, 4)
         }
         .background(Color(.systemBlue))
         VStack {
            Text(vehiclePlate!)
               .font(.system(size: 10, weight: .bold, design: .monospaced))
               .foregroundColor(.black)
               .padding(.horizontal, 5)
         }
      }
      .background(Color(.white))
      .border(Color(.systemBlue))
      .cornerRadius(2)
   }


   var body: some View {
      if (busNumber != nil) {
         
         if (vehiclePlate != nil) {
            VStack {
               if (toggleIdentifier) {
                  busNumberView
               } else {
                  licensePlateView
               }
            }
            .onTapGesture {
               TapticEngine.impact.feedback(.light)
               self.toggleIdentifier = !toggleIdentifier
            }
         } else {
            busNumberView
         }
         
      } else {
         placeholder
      }
   }

}
