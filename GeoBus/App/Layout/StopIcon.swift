//
//  TimeLeft.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct StopIcon: View {
   
   public let orderInRoute: Int?
   public let direction: CarrisNetworkModel.Direction?
   public let isSelected: Bool
   
   init(orderInRoute: Int? = nil, direction: CarrisNetworkModel.Direction? = nil, isSelected: Bool = false) {
      self.orderInRoute = orderInRoute
      self.direction = direction
      self.isSelected = isSelected
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
      if (self.isSelected) {
         return Color("StopSelectedBorder")
      } else {
         switch direction {
            case .ascending:
               return Color("StopAscendingBorder")
            case .descending:
               return Color("StopDescendingBorder")
            case .circular:
               return Color("StopCircularBorder")
            case .none:
               return Color("StopCircularBorder")
         }
      }
   }
   
   private var backgroundColor: Color {
      if (self.isSelected) {
         return Color("StopSelectedBackground")
      } else {
         switch direction {
            case .ascending:
               return Color("StopAscendingBackground")
            case .descending:
               return Color("StopDescendingBackground")
            case .circular:
               return Color("StopCircularBackground")
            case .none:
               return Color("StopCircularBackground")
         }
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
               .foregroundColor(.white)
               .animation(.default, value: self.textSize)
         } else {
            Image(systemName: "mappin")
               .font(.system(size: self.textSize, weight: .bold))
               .foregroundColor(.white)
               .animation(.default, value: self.textSize)
         }
      }
   }
   
}
