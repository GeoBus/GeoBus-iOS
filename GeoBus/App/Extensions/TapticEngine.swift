//
//  TapticEngine.swift
//
//  Created by Keisuke Shoji on 2017/04/09.
//  Copyright © 2017年 Keisuke Shoji. All rights reserved.
//
import UIKit

/// Generates iOS Device vibrations by UIFeedbackGenerator.
open class TapticEngine {

   public static let impact: Impact = .init()


   /// Wrapper of `UIImpactFeedbackGenerator`
   open class Impact {
      /// Impact feedback styles
      ///
      /// - light: A impact feedback between small, light user interface elements.
      /// - medium: A impact feedback between moderately sized user interface elements.
      /// - heavy: A impact feedback between large, heavy user interface elements.
      public enum ImpactStyle {
         case light, medium, heavy
      }

      private var style: ImpactStyle = .light
      private var generator: Any? = Impact.makeGenerator(.light)

      private static func makeGenerator(_ style: ImpactStyle) -> Any? {
         guard #available(iOS 10.0, *) else { return nil }

         let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
         switch style {
            case .light:
               feedbackStyle = .light
            case .medium:
               feedbackStyle = .medium
            case .heavy:
               feedbackStyle = .heavy
         }
         let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
         generator.prepare()
         return generator
      }

      private func updateGeneratorIfNeeded(_ style: ImpactStyle) {
         guard self.style != style else { return }

         generator = Impact.makeGenerator(style)
         self.style = style
      }

      public func feedback(_ style: ImpactStyle) {
         guard #available(iOS 10.0, *) else { return }

         updateGeneratorIfNeeded(style)

         guard let generator = generator as? UIImpactFeedbackGenerator else { return }

         generator.impactOccurred()
         generator.prepare()
      }

      public func prepare(_ style: ImpactStyle) {
         guard #available(iOS 10.0, *) else { return }

         updateGeneratorIfNeeded(style)

         guard let generator = generator as? UIImpactFeedbackGenerator else { return }

         generator.prepare()
      }
   }
}
