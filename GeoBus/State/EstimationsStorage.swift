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
  
  /* * */
  /* MARK: - Settings */
  
  private let endpoint = "https://carris.tecmic.com/api/v2.8/Estimations/busStop/"
  private let howManyResults = "/top/5" // results
  private let syncInterval = 100.0 // seconds
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Variables */
  
  private var stopPublicId: String = ""
  private var timer: Timer? = nil
  
  @Published var estimations: [Estimation] = []
  @Published var isLoading: Bool = false
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Initialization */
  
  
  /* * * *
   * INIT-
   * At initialization, estimationsStorage will:
   *  1. Set the stop publicId for which to get estimations from;
   *  2. Get estimations immediately for the set stopPublicId;
   *  3. Initiate the timer to update estimations every x seconds.
   */
  init(publicId: String) {
    self.stopPublicId = publicId
    self.getEstimations()
    self.timer = Timer.scheduledTimer(
      timeInterval: self.syncInterval,
      target: self,
      selector: #selector(self.getEstimations),
      userInfo: nil,
      repeats: true
    )
  }
  
  
  /* * * *
   * INIT: GET ESTIMATIONS
   * This function will call the Carris API directly to retrieve estimations for the set stopPublicId,
   * while storing them in the estimations array. It must have @objc flag because Timer is written in Objective-C...
   */
  @objc func getEstimations() {
    
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
        print("Error info: \(error.localizedDescription)")
      }
      
    }
    
    task.resume()
  
  }
  
  
  /* MARK: Initialization - */
  /* * */
  
  
}
