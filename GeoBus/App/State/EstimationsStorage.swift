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

   private let syncInterval = 30.0 // seconds
   private let howManyResults = "/top/5" // results
   private let endpoint = "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.9/Estimations/busStop/"

   /* * */



   /* * */
   /* MARK: - Private Variables */

   private var stopPublicId: String = ""
   private var timer: Timer? = nil
   private var authentication: Authentication

   /* * */



   /* * */
   /* MARK: - Published Variables */

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
      self.authentication = Authentication()
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
    * while storing them in the estimations array. It must have @objc flag because Timer is written in Objective-C.
    */
   @objc func getEstimations() {

      if stopPublicId.isEmpty { return }

      isLoading = true

      var request = URLRequest(url: URL(string: endpoint + stopPublicId + howManyResults)!)

      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
      request.setValue("Bearer \(authentication.authToken ?? "-")", forHTTPHeaderField: "Authorization")

      // Create the task
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

         let httpResponse = response as? HTTPURLResponse

         // Check status of response
         if httpResponse?.statusCode == 401 {
            //        self.authentication.authenticate()
            self.getEstimations()
         } else if httpResponse?.statusCode != 200 {
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
