//
//  Helpers.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation
import SwiftUI



open class Helpers {

   /* MARK: - Get Route Kind */

   // Discover the Route kind by analysing the route number.

   static func getKind(by routeNumber: String) -> CarrisNetworkModel.Kind {

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


   /* MARK: - Get Theme Colors */

   // Centralized functions that retrieve theme colors.

   static func getBackgroundColor(for routeNumber: String) -> Color {
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

   static func getForegroundColor(for routeNumber: String) -> Color {
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



   /* MARK: - Get Time Interval */

   // Transform an ISO Timestamp String into relative date components.

   enum TimeRelativeToNow {
      case past
      case future
   }

   
   static func getTimeInterval(for isoDateString: String, in timeRelation: TimeRelativeToNow) -> Double {
      
      // Setup Date Formatter
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      
      // Parse ISO Timestamp using the Date Formatter
      let now = Date()
      let dateObj = dateFormatter.date(from: isoDateString) ?? now
      let seconds = now.timeIntervalSince(dateObj) // in seconds
      
      // Use the configured Date Components Formatter to generate the string.
      switch timeRelation {
         case .past:
            return seconds
         case .future:
            return -seconds
      }
      
   }
   
   
   static func getTimeString(for isoDateString: String, in timeRelation: TimeRelativeToNow, style: DateComponentsFormatter.UnitsStyle, units: NSCalendar.Unit, alwaysPositive: Bool = false) -> String {
      
      var seconds = self.getTimeInterval(for: isoDateString, in: timeRelation)
      
      // Setup Date Components Formatter
      let dateComponentsFormatter = DateComponentsFormatter()
      dateComponentsFormatter.unitsStyle = style
      dateComponentsFormatter.allowedUnits = units
      dateComponentsFormatter.includesApproximationPhrase = false
      dateComponentsFormatter.includesTimeRemainingPhrase = false
      dateComponentsFormatter.allowsFractionalUnits = false
      
      if (alwaysPositive && seconds < 30) {
         seconds = 30.1 // Do not let it be smaller than 30 seconds
         dateComponentsFormatter.allowedUnits = .second
      } else if (alwaysPositive && seconds < 60) {
         seconds = 60.1 // Do not let it be smaller than 1 min
         dateComponentsFormatter.allowedUnits = .minute
      }

      // Use the configured Date Components Formatter to generate the string.
      return dateComponentsFormatter.string(from: seconds) ?? "?"

   }
   
   
   
   
   
   
   
   
   
   
   
   
   
   static func getLastSeenTime(since isoDateString: String) -> Int {
      
      // Setup Date Formatter
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      
      // Parse ISO Timestamp using the Date Formatter
      let now = Date()
      let dateObj = dateFormatter.date(from: isoDateString) ?? now
      let seconds = now.timeIntervalSince(dateObj) // in seconds
      
      return Int(seconds)
      
   }
   
   
   static func getSecondsFromISO8601DateString(_ dateString: String) -> Int {
      let formattedDateObject = ISO8601DateFormatter().date(from: dateString)
      return Int(formattedDateObject?.timeIntervalSinceNow ?? -1)
   }
   
   
   
   /* * */
   /* MARK: - CALCULATE VEHICLE ANGLE */
   /* Calculate the angle in radians from the last two locations to correctly point */
   /* the front of the vehicle to its current direction. */
   
   static func getAngleInRadians(prevLat: Double, prevLng: Double, currLat: Double, currLng: Double) -> Double {
      // and return response to the caller
      let x = currLat - prevLat;
      let y = currLng - prevLng;
      
      var teta: Double;
      // Angle is calculated with the arctan of ( y / x )
      if (x == 0){ teta = .pi / 2 }
      else { teta = atan(y / x) }
      
      // If x is negative, then the angle is in the symetric quadrant
      if (x < 0) { teta += .pi }
      
      return teta - (.pi / 2) // Correction cuz Apple rotates clockwise
      
   }
   
}
