//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

class RoutesStorage {
  
  var favorites: [Route] = []
  
  var recent: [Route] = []
  
  var all: [Route] = []
  
  
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  
  init() {
    self.getAllRoutes()
  }
  
  
  /* * * *
   *
   * Get Routes
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  private func getAllRoutes() {
    
    // Setup the url
    let url = URL(string: endpoint + "/routes/")!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at getRoutes()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Route].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.all.append(contentsOf: decodedData)
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  
}
