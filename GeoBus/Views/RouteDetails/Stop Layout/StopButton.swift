//
//  StopButton.swift
//  GeoBus
//
//  Created by João on 22/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import SwiftUI

struct StopButton: View {
  
  var stop: Stop
  
  @State var isSelected = false
  
  var body: some View {
    
    Button(action: {
      self.isSelected = !self.isSelected
    }) {
      
      VStack {
        
        HStack {
          VStack {
            Text("23")
              .font(.caption)
              .fontWeight(.bold)
              .foregroundColor(.black)
          }
          .padding(.all, 7)
          .background(Color.yellow)
          .cornerRadius(.infinity)
          
          Text(stop.name ?? "-")
            .fontWeight(.medium)
            .foregroundColor(.black)
          
          Spacer()
        }
        .padding()
        
        VStack {
          
          if isSelected { HorizontalLine(color: isSelected ? Color(red: 0.95, green: 0.95, blue: 0.95) : .white) }
          
          if isSelected {
            
            VStack(alignment: .leading) {
              
              HStack {
                Text("Next on this stop")
                  .font(.footnote)
                  .fontWeight(.medium)
                  .foregroundColor(.gray)
                Spacer()
                EstimatedIcon()
              }
              .padding(.bottom, 8)
              
              HStack {
                VehicleAnnotationView(title: "728")
                Text("to")
                  .font(.footnote)
                  .foregroundColor(.gray)
                Text("Portas de Benfica")
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(.black)
                Spacer()
                Text("in ±")
                  .font(.footnote)
                  .foregroundColor(.gray)
                Text("2 min")
                  .font(.body)
                  .fontWeight(.medium)
                  .foregroundColor(.black)
              }
              
            }
            .padding(.horizontal)
            .padding(.bottom)
            
          }
          
        }
        .padding(.top, -12)
        
      }
      .background(isSelected ? Color(red: 0.97, green: 0.97, blue: 0.97) : Color(red: 0.95, green: 0.95, blue: 0.95))
      .cornerRadius(10)
      .padding(.bottom, isSelected ? 15 : 0)
      .shadow(color: Color(red: 0.85, green: 0.85, blue: 0.85), radius: isSelected ? 1 : 0, x: 0, y: 0)
      .shadow(color: Color(red: 0.95, green: 0.95, blue: 0.95), radius: isSelected ? 25 : 0, x: 0, y: isSelected ? 2 : 0)
    }
  }
}
