//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class EndpointStorage: ObservableObject {
  
  /* * */
  /* MARK: - Settings */
  
  private var syncInterval = 10.0 // seconds
  private var repository = "https://raw.githubusercontent.com/GeoBus/api-endpoint/master/carris.json"
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Published Variables */
  
  @Published var endpoint: String = ""
  @Published var token: String = ""
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Private Variables */
  
  private var timer: Timer? = nil
  
  /* * */
  
  
  
  
  init() {
    self.fetchEndpoint()
    self.timer = Timer.scheduledTimer(
      timeInterval: syncInterval,
      target: self,
      selector: #selector(self.fetchEndpoint),
      userInfo: nil,
      repeats: true
    )
  }
  
  
  
  /* * * *
   * STATE: GET VEHICLES
   * This function calls the GeoBus API and receives vehicle metadata, including positions, for the set route number,
   * while storing them in the vehicles array. It also formats VehicleAnnotations and stores them in the annotations array.
   * It must have @objc flag because Timer is written in Objective-C.
   */
  @objc private func fetchEndpoint() {
    
    // Setup the url
    let url = URL(string: repository)!
    
    // Configure a session
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create the task
    let task = session.dataTask(with: url) { (data, response, error) in
      
      let httpResponse = response as? HTTPURLResponse
      
      // Check status of response
      if httpResponse?.statusCode != 200 {
        print("Error: API failed at fetchEndpoint()")
        return
      }
      
      do {
        
        let decodedData = try JSONDecoder().decode(Endpoint.self, from: data!)
        
        OperationQueue.main.addOperation {
          
          print(decodedData)
          
          self.endpoint = decodedData.endpoint
          self.token = decodedData.token
          
        }
        
      } catch {
        print("Error info: \(error)")
      }
    }
    
    task.resume()
    
  }
  
  
  /* MARK: State - */
  /* * */
  
  
}
