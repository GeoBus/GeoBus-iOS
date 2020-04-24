//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class EstimationsStorage: ObservableObject {
  
  var stopPublicId: String = ""
  
  @Published var estimations: [Estimation] = []
  
  @Published var isLoading: Bool = false
  
  
  private let endpoint = "https://carris.tecmic.com/api/v2.8/Estimations/busStop/"
  private let howManyResults = "/top/5"
  
  
  private var state = State.idle {
    // We add a property observer on 'state', which lets us
    // run a function on each value change.
    didSet { stateDidChange() }
  }
  
  private var timer: Timer? = nil
  
  
  
  
  func set(publicId: String, state: State) {
    self.stopPublicId = publicId // route must be updated first, otherwise state will update without a route being set
    self.state = state
  }
  
  func set(state: State) {
    self.state = state
  }
  
  
  func stateDidChange() {
    switch state {
      case .idle:
        stopPublicId = ""
        timer?.invalidate()
        timer = nil
        break
      case .syncing:
        timer = Timer.scheduledTimer(
          timeInterval: 60.0,
          target: self,
          selector: #selector(self.syncEstimations),
          userInfo: nil,
          repeats: true
        )
        self.syncEstimations()
        break
    }
  }
  
  
  
  @objc func syncEstimations() { //_ timer : Timer
    if state == .syncing {
      getEstimations()
    }
  }
  
  
  
  /* * * *
   *
   * Get Stops Estimations
   * This function gets stops from each route instance
   * and stores them in the Route variable
   *
   */
  func getEstimations() {
    
    if stopPublicId.isEmpty { return }
    
    isLoading = true
    
    // Setup the url
    let url = URL(string: endpoint + stopPublicId + howManyResults)!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at getEstimations()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode([Estimation].self, from: data!)
        
        OperationQueue.main.addOperation {
          self.estimations.removeAll()
          self.estimations.append(contentsOf: decodedData)
          self.isLoading = false
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
}



// MARK: - Extension for state control

extension EstimationsStorage {
  enum State {
    case idle
    case syncing
  }
}
