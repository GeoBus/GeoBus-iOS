//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation
import Boutique

class Authentication: ObservableObject {

   /* MARK: - Overview */

   // 1. AUTHENTICATE
   //    Orchestrate steps to ensure valid authentication flow.

   // 2. FETCH LATEST AVAILABLE CREDENTIAL FROM SERVER
   //    This improves reliability as valid credentials can become
   //    invalid at a moment's notice. Retrieving from an endpoint
   //    allows for a quick server fix and avoids an App Store submission.

   // 3. GET VALID AUTH TOKEN AND REFRESH TOKEN FROM AUTHENTICATION API
   //    Fetch the Carris Authentication API to retrieve a valid authToken
   //    and refreshToken to process further requests.


   /* MARK: - Variables */

   private var retries = 3

   @StoredValue(key: "endpoint")
   var endpoint: String? = nil

   @StoredValue(key: "apiKey")
   var apiKey: String? = nil

   @StoredValue(key: "authToken")
   var authToken: String? = nil

   @StoredValue(key: "refreshToken")
   var refreshToken: String? = nil


   /* MARK: - Init */

   // Initiate authentication on init to save time.

   init() {
      authenticate()
   }


   /* MARK: - 1. AUTHENTICATE */

   // This function agregates all the steps required for authentication.

   func authenticate() {

      Task {

         if (refreshToken != nil) {
            do {
               print("Authorizing with Carris API using refreshToken...")
               try await fetchAuthorization(token: refreshToken!, type: "refresh")
            } catch {
               print("Clearing saved refreshToken...")
               self.$refreshToken.reset()
               self.authenticate()
               return
            }
         } else if (apiKey != nil) {
            do {
               print("Authorizing with Carris API using apiKey...")
               try await fetchAuthorization(token: apiKey!, type: "apikey")
            } catch {
               print("Clearing saved apiKey...")
               self.$apiKey.reset()
               self.authenticate()
               return
            }
         } else {
            do {
               if (retries > 0) {
                  print("Retrieving latest credential from server...")
                  try await fetchLatestCredential()
                  authenticate()
                  retries -= 1
                  return
               }
            } catch {
               print("Unkown Error")
               return
            }
         }

      }

   }


   /* MARK: - 2. FETCH LATEST AVAILABLE CREDENTIAL FROM SERVER */

   // Get latest available Credential from endpoint

   func fetchLatestCredential() async throws {

      var request = URLRequest(url: URL(string: "https://joao.earth/api/geobus/carris_auth")!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "GET"

      let (rawCredential, _) = try await URLSession.shared.data(for: request)
      let decodedCredential = try JSONDecoder().decode(CredentialResponse.self, from: rawCredential)
      self.$endpoint.set(decodedCredential.endpoint)
      self.$apiKey.set(decodedCredential.token)

   }


   /* MARK: - 3. GET VALID AUTH TOKEN AND REFRESH TOKEN FROM AUTHENTICATION API */

   // Get authorization tokens from Carris API

   func fetchAuthorization(token: String, type: String) async throws {

      var request = URLRequest(url: URL(string: "https://" + self.endpoint! + "/gateway/authenticationapi/authorization/sign")!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "POST"

      request.httpBody = try JSONSerialization.data(withJSONObject: ["token": token, "type": type], options: .prettyPrinted)

      let (data, _) = try await URLSession.shared.data(for: request)

      let parsedAuthorization = try JSONDecoder().decode(AuthorizationResponse.self, from: data)

      self.$refreshToken.set(parsedAuthorization.refreshToken)
      self.$authToken.set(parsedAuthorization.authorizationToken)

   }


}
