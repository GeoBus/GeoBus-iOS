//
//  TimeLeft.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct TimeLeft: View {
   
   public let timeString: String?
   
   private let countdownUnits: NSCalendar.Unit
   private let countdownTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State private var countdownValue: Double = 0
   @State private var countdownString: String?
   
   
   init(time: String?, units: NSCalendar.Unit = [.hour, .minute]) {
      self.timeString = time
      self.countdownUnits = units
   }
   
   
   func setCountdownString(_ value: Any?) {
      if (timeString != nil) {
         self.countdownValue = Helpers.getTimeInterval(for: self.timeString!, in: .future)
         self.countdownString = Helpers.getTimeString(for: self.timeString!, in: .future, style: .short, units: self.countdownUnits, alwaysPositive: true)
      }
   }
   
   
   var positiveTime: some View {
      HStack(spacing: 5) {
         Image(systemName: "plusminus")
            .font(.footnote)
            .foregroundColor(Color(.tertiaryLabel))
         Text(self.countdownString!)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
      }
   }
   
   
   var negativeTime: some View {
      HStack(spacing: 5) {
         Image(systemName: "lessthan")
            .font(.footnote)
            .foregroundColor(Color(.tertiaryLabel))
         Text(self.countdownString!)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
      }
   }
   
   
   var invalidValue: some View {
      Image(systemName: "circle.dashed")
         .font(Font.system(size: 15, weight: .medium))
         .foregroundColor(Color(.secondaryLabel))
   }
   
   
   var body: some View {
      VStack {
         if (countdownString != nil) {
            if (countdownValue > 0) {
               positiveTime
            } else {
               negativeTime
            }
         } else {
            invalidValue
         }
      }
      .onAppear() { setCountdownString(nil) }
      .onChange(of: timeString, perform: setCountdownString)
      .onReceive(countdownTimer, perform: setCountdownString)
   }
   
}
