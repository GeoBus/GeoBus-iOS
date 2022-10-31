//
//  RouteBadgePill.swift
//  GeoBus
//
//  Created by João on 29/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import SwiftUI

struct RouteBadgePill: View {
   
   public let routeNumber: String?
   
   private let fontSize: CGFloat = 13
   private let fontWeight: Font.Weight = .heavy
   private let cornerRadius: CGFloat = 10
   private let paddingHorizontal: CGFloat = 7
   private let paddingVertical: CGFloat = 2
   
   @State private var placeholderOpacity: Double = 1
   private let placeholderColor: Color = Color("PlaceholderShape")
   
   
   var placeholder: some View {
      VStack {
         Text("000")
            .font(Font.system(size: fontSize, weight: fontWeight))
            .lineLimit(1)
            .foregroundColor(.clear)
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
      }
      .background(placeholderColor)
      .cornerRadius(cornerRadius)
      .opacity(placeholderOpacity)
      .animatePlaceholder(binding: $placeholderOpacity)
   }
   
   
   var actualContent: some View {
      VStack {
         Text(routeNumber!)
            .font(Font.system(size: fontSize, weight: fontWeight))
            .lineLimit(1)
            .foregroundColor(Helpers.getForegroundColor(for: routeNumber!))
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
      }
      .background(Helpers.getBackgroundColor(for: routeNumber!))
      .cornerRadius(cornerRadius)
   }
   
   
   var body: some View {
      if (routeNumber != nil) {
         actualContent
      } else {
         placeholder
      }
   }
   
}
