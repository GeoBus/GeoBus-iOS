//
//  TimeLeft.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/10/2022.
//

import SwiftUI

struct TimeLeft: View {
   
   public let time: String?
   private let countdownTimer = Timer.publish(every: 1 /* seconds */, on: .main, in: .common).autoconnect()
   
   @State var timeLeftString: String = ""
   
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
         Text(self.timeLeftString)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
            .onAppear() {
               self.timeLeftString = Helpers.getTimeString(for: self.time ?? "", in: .future, style: .short, units: [.hour, .minute])
            }
            .onReceive(countdownTimer) { event in
               self.timeLeftString = Helpers.getTimeString(for: self.time ?? "", in: .future, style: .short, units: [.hour, .minute])
            }
      }
   }
   
   var body: some View {
      if (time != nil) {
         content
      } else {
         loading
      }
   }
   
}
