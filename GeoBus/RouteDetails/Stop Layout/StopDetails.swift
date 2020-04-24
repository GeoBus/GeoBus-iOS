//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct StopDetails: View {
  
  var stop: Stop
  var direction: Int
  
  @State var isSelected = false
  
  var body: some View {
    
    Button(action: {
      self.isSelected = !self.isSelected
    }) {
      
      VStack {
        
        HStack {
          VStack {
            Text(stop.orderInRoute != nil ? (stop.orderInRoute! < 10 ? "0\(stop.orderInRoute!)" : "\(stop.orderInRoute!)" ) : "-")
              .font(.caption)
              .fontWeight(.bold)
              .foregroundColor(Color(.white))
          }
          .padding(7)
          .background(getColor(for: direction))
          .cornerRadius(.infinity)
          .padding(.trailing, 3)
          
          
          Text(stop.name)
            .fontWeight(.medium)
            .foregroundColor(Color(.label))
          
          Spacer()
        }
        .padding()
        
        VStack {
          
          if isSelected { HorizontalLine() } // color: isSelected ? Color(red: 0.95, green: 0.95, blue: 0.95) : .white
          
          if isSelected {
            
            VStack(alignment: .leading) {
              
              HStack {
                Text("Next on this stop")
                  .font(.footnote)
                  .fontWeight(.medium)
                  .foregroundColor(Color(.tertiaryLabel))
                Spacer()
                EstimatedIcon()
              }
              .padding(.bottom, 8)
              
              HStack {
                VehicleAnnotationView(title: "728")
                Text("to")
                  .font(.footnote)
                  .foregroundColor(Color(.tertiaryLabel))
                Text("Portas de Benfica")
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(Color(.label))
                Spacer()
                Text("in ±")
                  .font(.footnote)
                  .foregroundColor(Color(.tertiaryLabel))
                Text("2 min")
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(Color(.label))
              }
              
            }
            .padding(.horizontal)
            .padding(.bottom)
            
          }
          
        }
        .padding(.top, -12)
        
      }
      .background(isSelected ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
      .cornerRadius(10)
      .padding(.bottom, isSelected ? 15 : 0)
      .shadow(color: Color(.secondarySystemBackground), radius: isSelected ? 1 : 0, x: 0, y: 0)
      .shadow(color: Color(.secondarySystemBackground), radius: isSelected ? 25 : 0, x: 0, y: isSelected ? 2 : 0)
    }
  }
  
  func getColor(for direction: Int) -> Color {
    switch direction {
      case 0: return Color(.systemGreen)
      case 1: return Color(.systemBlue)
      default: return Color(.systemBlue)
    }
  }
  
}
