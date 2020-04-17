//
//  GeoBusAPI.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine



struct GeoBusAPI {
  
  var routeNumber: String
  @Binding var vehicleLocations: VehicleLocations
  @Binding var isLoading: Bool
  
  
  func getVehicleStatuses() {
    
    self.isLoading = true
    
    // Create a configuration
    let configuration = URLSessionConfiguration.default
    
    // Create a session
    let session = URLSession(configuration: configuration)
    
    // Setup the url
    let url = URL(string: "https://geobus-api.herokuapp.com/vehicles/" + routeNumber)!
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      // Check status of response
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
        return
      }
      
      do {
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([Vehicle].self, from: data)
        
        OperationQueue.main.addOperation {
          
          self.vehicleLocations.old.append(contentsOf: self.vehicleLocations.new)
          self.vehicleLocations.new.removeAll()
          
          
          for item in decodedData {
            self.vehicleLocations.new.append(
              VehicleMapAnnotation(title: String(item.busNumber), subtitle: item.direction, latitude: item.lat, longitude: item.lng)
            )
          }
        }
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
}
