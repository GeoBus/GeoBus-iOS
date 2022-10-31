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
   
   @State private var countdownValue: Int = 0
   @State private var countdownString: String = ""
   
   
   init(time: String?, units: NSCalendar.Unit = [.hour, .minute]) {
      self.timeString = time
      self.countdownUnits = units
   }
   
   
   func setCountdownString(_ value: Any) {
      if (timeString != nil) {
         self.countdownValue = Helpers.getLastSeenTime(since: self.timeString!)
         print("countdownValue: \(countdownValue)")
         self.countdownString = Helpers.getTimeString(for: self.timeString!, in: .future, style: .short, units: self.countdownUnits)
      }
   }
   
   
   var loading: some View {
      HStack(spacing: 3) {
         ProgressView()
            .scaleEffect(0.55)
      }
   }
   
   var content: some View {
      HStack(spacing: 5) {
         Image(systemName: "plusminus")
            .font(.footnote)
            .foregroundColor(Color(.tertiaryLabel))
         Text(self.countdownString)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .onChange(of: timeString, perform: setCountdownString)
            .onReceive(countdownTimer, perform: setCountdownString)
      }
   }
   
   var icon: some View {
      Image(systemName: "figure.walk.arrival")
         .font(.body)
         .fontWeight(.medium)
         .foregroundColor(Color(.systemBlue))
   }
   
   
   var body: some View {
      if (timeString != nil) {
         if (countdownValue < 0) {
            icon
         } else {
            content
         }
      } else {
         loading
      }
   }
   
}
