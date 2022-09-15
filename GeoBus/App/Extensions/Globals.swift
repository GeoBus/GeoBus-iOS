//
//  Helpers.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation
import SwiftUI


enum Kind: Codable, Equatable {
   case tram
   case neighborhood
   case night
   case elevator
   case regular
}


class Globals {

   /* MARK: - Get Route Kind */

   // Discover the Route kind by analysing the route number.

   func getKind(by routeNumber: String) -> Kind {

      if (routeNumber.suffix(1) == "B") {
         // Neighborhood buses end with "B"
         return .neighborhood

      } else if (routeNumber.suffix(1) == "E") {
         // Trams and Elevators end with "E"
         if (routeNumber.prefix(1) == "5") {
            // and Elevators start with "5"
            return .elevator
         } else {
            // All other options starting with "E" are trams
            return .tram
         }

      } else if (routeNumber.prefix(1) == "2") {
         // Night service starts with "2"
         return .night

      } else {
         // All other options are regular service
         return .regular

      }

   }


   func getLastSeenTime(since lastGpsTime: String) -> Int {

      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

      let now = Date()
      let estimation = formatter.date(from: lastGpsTime) ?? now

      let seconds = now.timeIntervalSince(estimation)

      return Int(seconds)

   }


   func getLastSeenTimeString(for secondsAmount: Int) -> String {
      let formatter = DateComponentsFormatter()
      formatter.unitsStyle = .short
      formatter.includesApproximationPhrase = false
      formatter.includesTimeRemainingPhrase = false
      formatter.allowedUnits = [.second, .minute, .hour]

      // Use the configured formatter to generate the string.
      return formatter.string(from: DateComponents(second: secondsAmount)) ?? "-"
   }

   func getLastSeenTimeString(for isoDateString: String) -> String {

      // style: DateComponentsFormatter.UnitsStyle, units: [NSCalendar.Unit]

      let formatter = DateComponentsFormatter()
      formatter.unitsStyle = .full
      formatter.includesApproximationPhrase = false
      formatter.includesTimeRemainingPhrase = false
      formatter.allowedUnits = [.second, .minute, .hour]

      let secondsAmount = getLastSeenTime(since: isoDateString)

      // Use the configured formatter to generate the string.
      return formatter.string(from: DateComponents(second: secondsAmount)) ?? "-"
   }


   func getBackgroundColor(for routeNumber: String) -> Color {
      let routeKind = getKind(by: routeNumber)
      switch routeKind {
         case .tram:
            return Color(red: 1.00, green: 0.85, blue: 0.00)
         case .neighborhood:
            return Color(red: 1.00, green: 0.55, blue: 0.40)
         case .night:
            return Color(red: 0.12, green: 0.35, blue: 0.70)
         case .elevator:
            return Color(red: 0.00, green: 0.60, blue: 0.40)
         case .regular:
            return Color(red: 1.00, green: 0.75, blue: 0.00)
      }
   }

   func getForegroundColor(for routeNumber: String) -> Color {
      let routeKind = getKind(by: routeNumber)
      switch routeKind {
         case .tram:
            return Color(.black)
         case .neighborhood:
            return Color(.white)
         case .night:
            return Color(.white)
         case .elevator:
            return Color(.white)
         case .regular:
            return Color(.black)
      }
   }
}
