//
//  TimeLeft.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct TimeLeft: View {
   
   public let timeString: String?
   public let vehicleDidArrive: Bool
   public let idleSeconds: Int
   
   private let countdownUnits: NSCalendar.Unit
   private let countdownTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State private var countdownValue: Double = 0
   @State private var countdownString: String?
   
   
   init(time: String?, vehicleDidArrive: Bool, idleSeconds: Int, units: NSCalendar.Unit = [.hour, .minute]) {
      self.timeString = time
      self.vehicleDidArrive = vehicleDidArrive
      self.idleSeconds = idleSeconds
      self.countdownUnits = units
   }
   
   
   func setCountdownString(_ value: Any?) {
      if (timeString != nil) {
         self.countdownValue = Helpers.getTimeInterval(for: self.timeString!, in: .future)
         self.countdownString = Helpers.getTimeString(for: self.timeString!, in: .future, style: .short, units: self.countdownUnits, alwaysPositive: true)
      }
   }
   
   
   var hasArrivedIcon: some View {
      Image(systemName: "checkmark.circle")
         .font(Font.system(size: 15, weight: .medium))
         .foregroundColor(Color("StopMutedText"))
   }
   
   var moreOrLessIcon: some View {
      Image(systemName: "plusminus")
         .font(.footnote)
         .foregroundColor(Color(.tertiaryLabel))
   }
   
   
   var lessThanIcon: some View {
      Image(systemName: "lessthan")
         .font(.footnote)
         .foregroundColor(Color(.tertiaryLabel))
   }
   
   var isIdleIcon: some View {
      Image(systemName: "exclamationmark.triangle.fill")
         .font(Font.system(size: 15, weight: .medium))
         .foregroundColor(Color("StopMutedText"))
   }
   
   var invalidValueIcon: some View {
      Image(systemName: "circle.dashed")
         .font(Font.system(size: 15, weight: .medium))
         .foregroundColor(Color(.secondaryLabel))
   }
   
   
   var body: some View {
      VStack {
         if (countdownString != nil) {
            HStack(spacing: 5) {
               if (!vehicleDidArrive) {
                  if (idleSeconds > 60) {
                     isIdleIcon
                  } else if (countdownValue > 60) {
                     moreOrLessIcon
                  } else if (countdownValue <= 60) {
                     lessThanIcon
                  }
                  Text(self.countdownString!)
                     .font(.body)
                     .fontWeight(.medium)
                     .foregroundColor(Color(.label))
               } else {
                  hasArrivedIcon
               }
            }
         } else {
            invalidValueIcon
         }
      }
      .onAppear() { setCountdownString(nil) }
      .onChange(of: timeString, perform: setCountdownString)
      .onReceive(countdownTimer, perform: setCountdownString)
   }
   
}
