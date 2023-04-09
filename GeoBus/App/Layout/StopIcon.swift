//
//  TimeLeft.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct StopIcon: View {
   
   public let style: Style
   public let orderInRoute: Int?
   
   init(style: Style = .standard, orderInRoute: Int? = nil, direction: CarrisNetworkModel.Direction? = nil) {
      self.orderInRoute = orderInRoute
      
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
      case mini
      case circular
      case ascending
      case descending
      case selected
      case muted
   }
   
   
   
   private var viewSize: CGFloat {
      switch style {
         case .standard, .ascending, .descending, .circular, .muted:
            return 25
         case .mini:
            return 10
         case .selected:
            return 25 * 1.5
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
            return Color("StopStandardBorder")
         case .mini:
            return Color("StopMiniBorder")
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
            return Color("StopStandardBackground")
         case .mini:
            return Color("StopMiniBackground")
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
            return Color("StopStandardText")
         case .mini:
            return Color("StopMiniText")
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
         Circle()
            .foregroundColor(self.backgroundColor)
            .frame(width: self.borderWidth, height: self.borderWidth)
         switch style {
            case .standard, .selected:
               Image(systemName: "mappin")
                  .font(.system(size: self.textSize, weight: .bold))
                  .foregroundColor(textColor)
            case .ascending, .descending, .circular, .muted:
               Text(String(self.orderInRoute!))
                  .font(.system(size: self.textSize, weight: .bold))
                  .foregroundColor(textColor)
            case .mini:
               EmptyView()
         }
      }
   }
   
}
