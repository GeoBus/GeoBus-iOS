//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class RoutesStorage: ObservableObject {
  
  @Published var selected: Route = Route()
  
  @Published var favorites: [Route] = []
  
  @Published var recent: [Route] = []
  
  @Published var all: [Route] = []
  
  
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
  
  
  
  
  func isSelected() -> Bool {
    return selected.routeNumber.count > 2
  }
  
  
  func select(route: Route) {
    self.selected = route
  }
  
  func select(with routeNumber: String) {
    
    let index = all.firstIndex(where: { (route) -> Bool in
      route.routeNumber == routeNumber // test if this is the item you're looking for
    }) ?? -1 // if the item does not exist,
    
    if index < 0 {
      self.selected = Route() // selected route is an empty route
    } else {
      self.selected = all[index]
    }
  }
  
  
  
}
