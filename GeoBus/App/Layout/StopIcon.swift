//
//  TimeLeft.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct StopIcon: View {
   
   public let orderInRoute: Int?
   public let style: Style
   public let isSelected: Bool
   
   init(orderInRoute: Int? = nil, direction: CarrisNetworkModel.Direction? = nil, style: Style = .standard, isSelected: Bool = false) {
      self.orderInRoute = orderInRoute
      self.isSelected = isSelected
      
      switch direction {
         case .ascending:
            self.style = .ascending
         case .descending:
            self.style = .descending
         case .circular:
            self.style = .circular
         case .none:
            self.style = style
      }
      
   }
   
   
   enum Style {
      case standard
      case circular
      case ascending
      case descending
      case selected
      case muted
   }
   
   
   // Properties:
   // The defaults for the icon
   private let size: CGFloat = 25
   private let multiplier: Double = 1.5
   
   
   private var viewSize: CGFloat {
      if (self.isSelected) {
         return self.size * self.multiplier
      } else {
         return self.size
      }
   }
   
   private var borderWidth: CGFloat {
      return self.viewSize - self.viewSize / 5
   }
   
   private var textSize: CGFloat {
      return self.viewSize / 2
   }
   
   private var borderColor: Color {
      switch style {
         case .standard:
            return Color("StopCircularBorder")
         case .ascending:
            return Color("StopAscendingBorder")
         case .descending:
            return Color("StopDescendingBorder")
         case .circular:
            return Color("StopCircularBorder")
         case .selected:
            return Color("StopSelectedBorder")
         case .muted:
            return Color("StopMutedBorder")
      }
   }
   
   private var backgroundColor: Color {
      switch style {
         case .standard:
            return Color("StopCircularBackground")
         case .ascending:
            return Color("StopAscendingBackground")
         case .descending:
            return Color("StopDescendingBackground")
         case .circular:
            return Color("StopCircularBackground")
         case .selected:
            return Color("StopSelectedBackground")
         case .muted:
            return Color("StopMutedBackground")
      }
   }
   
   private var textColor: Color {
      switch style {
         case .standard:
            return Color("StopCircularText")
         case .ascending:
            return Color("StopAscendingText")
         case .descending:
            return Color("StopDescendingText")
         case .circular:
            return Color("StopCircularText")
         case .selected:
            return Color("StopSelectedText")
         case .muted:
            return Color("StopMutedText")
      }
   }
   
   
   var body: some View {
      ZStack {
         Circle()
            .foregroundColor(self.borderColor)
            .frame(width: self.viewSize, height: self.viewSize)
            .animation(.default, value: self.borderColor)
            .animation(.default, value: self.viewSize)
         Circle()
            .foregroundColor(self.backgroundColor)
            .frame(width: self.borderWidth, height: self.borderWidth)
            .animation(.default, value: self.backgroundColor)
            .animation(.default, value: self.borderWidth)
         if (self.orderInRoute != nil) {
            Text(String(self.orderInRoute!))
               .font(.system(size: self.textSize, weight: .bold))
               .foregroundColor(textColor)
               .animation(.default, value: self.textSize)
         } else {
            Image(systemName: "mappin")
               .font(.system(size: self.textSize, weight: .bold))
               .foregroundColor(textColor)
               .animation(.default, value: self.textSize)
         }
      }
   }
   
}
