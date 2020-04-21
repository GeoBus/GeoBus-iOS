//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class StopsStorage: ObservableObject {
  
  @Published var stops: [Stop] = []
  
  @Published var annotations: [StopAnnotation] = []
  
  
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  
  /* * * *
   *
   * Get Routes
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  func getStops(for  routeNumber: String) {
    
    // Setup the url
    let url = URL(string: endpoint + "/stops/" + routeNumber)!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at getStops()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Stop].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.stops.removeAll()
          self.stops.append(contentsOf: decodedData)
          
          self.annotations.removeAll()
          for item in self.stops {
            self.annotations.append(
              StopAnnotation(
                title: String(item.name ?? "-"),
                subtitle: String(item.publicId ?? "-"),
                latitude: item.lat,
                longitude: item.lng
              )
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
