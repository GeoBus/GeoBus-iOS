//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class VehiclesStorage: ObservableObject {
  
  var route: String?
  
  @Published var vehicles: [Vehicle] = []
  
  @Published var annotations: [VehicleAnnotation] = []
  
  
  private var endpoint = "https://geobus-api.herokuapp.com"
  
  private var state = State.idle {
    // We add a property observer on 'state', which lets us
    // run a function on each value change.
    didSet { stateDidChange() }
  }
  
  var timer: Timer? = nil
  
  
  func set(route: String, state: State) {
    self.route = route // route must be updated first, otherwise state will update without a route being set
    self.state = state
  }
  
  func set(state: State) {
    self.route = nil
    self.state = state
  }
  
  
  func stateDidChange() {
    switch state {
      case .idle:
        timer = nil
        break
      case .syncing:
        timer = Timer.scheduledTimer(
          timeInterval: 20.0,
          target: self,
          selector: #selector(self.syncVehicles),
          userInfo: nil,
          repeats: true
        )
        self.syncVehicles()
        break
    }
  }
  
  
  
  @objc func syncVehicles() { //_ timer : Timer
    if state == .syncing {
      getVehicles()
    }
  }
  
  
  
  /* * * *
   *
   * Get Routes
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  @objc func getVehicles() {
    
    guard route != nil else { return }
    
    // Setup the url
    let url = URL(string: endpoint + "/vehicles/" + route!)!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at getVehicles()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Vehicle].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.vehicles.removeAll()
          self.vehicles.append(contentsOf: decodedData)
          
          self.annotations.removeAll()
          for item in self.vehicles {
            self.annotations.append(
              VehicleAnnotation(
                title: String(item.routeNumber ?? "-"),
                subtitle: String(item.lastStopOnVoyageName ?? "-"),
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




// MARK: - Extension for state control

extension VehiclesStorage {
  enum State {
    case idle
    case syncing
  }
}
