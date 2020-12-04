//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Combine

class Authentication: ObservableObject {
  
  /* * */
  /* MARK: - Settings */
  
  private var endpoint = "https://gateway.carris.pt/gateway/authenticationapi/authorization/sign"
  private var refreshToken = ""
  
  /* * */
  
  
  
  /* * */
  /* MARK: - Published Variables */
  
  @Published var authorizationToken: String = ""
  
  /* * */
  
  
  init() {
    
//    statements
    
  }
  
  

  /* * * *
   * INIT: RETRIEVE FAVORITES
   * This function retrieves favorites from iCloud Key-Value-Storage.
   */
  func retrieveRefreshToken() {
    
    // Get from iCloud
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.synchronize()
    let savedFavorites = iCloudKeyStore.array(forKey: "favoriteRoutes") as? [String] ?? []
    
    // Save to array
    for routeNumber in savedFavorites {
      let route = findRoute(from: routeNumber)
      if route != nil {
        self.favorites.append( route! )
      }
    }
    
  }
  
  /* * * *
   * FAVORITES: SAVE FAVORITE
   * This function saves a representation of the routes stored in the favorites array
   * to iCloud Key-Value-Store. This function should be called whenever a change
   * in favorites occurs, to ensure consistency across devices.
   */
  func saveRefreshToken() {
    let iCloudKeyStore = NSUbiquitousKeyValueStore()
    iCloudKeyStore.set(refreshToken, forKey: "refreshToken")
    iCloudKeyStore.synchronize()
  }
  
  
  
  
  /* * * *
   * STATE: GET VEHICLES
   * This function calls the GeoBus API and receives vehicle metadata, including positions, for the set route number,
   * while storing them in the vehicles array. It also formats VehicleAnnotations and stores them in the annotations array.
   * It must have @objc flag because Timer is written in Objective-C.
   */
  private func authenticate() {
    
    // Setup the url
    let url = URL(string: endpoint)!
    
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
        
        let decodedData = try JSONDecoder().decode(Authorization.self, from: data!)
        
        OperationQueue.main.addOperation {
          
          self.authorizationToken = decodedData.authorizationToken
          self.refreshToken = decodedData.refreshToken
          
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
