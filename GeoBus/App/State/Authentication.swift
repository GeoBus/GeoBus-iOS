//
//  Authentication.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

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

   @Published var endpoint: String? = nil
   @Published var apiKey: String? = nil
   @Published var refreshToken: String? = nil
   @Published var authToken: String? = nil


   init() {
      self.endpoint = UserDefaults.standard.string(forKey: "auth_endpoint")
      self.apiKey = UserDefaults.standard.string(forKey: "auth_apiKey")
      self.refreshToken = UserDefaults.standard.string(forKey: "auth_refreshToken")
      self.authToken = UserDefaults.standard.string(forKey: "auth_authToken")
   }


   func saveCredentials() {
      UserDefaults.standard.set(endpoint, forKey: "auth_endpoint")
      UserDefaults.standard.set(apiKey, forKey: "auth_apiKey")
      UserDefaults.standard.set(refreshToken, forKey: "auth_refreshToken")
      UserDefaults.standard.set(authToken, forKey: "auth_authToken")
   }



   /* MARK: - RECEIVE APPSTATE */

   var appstate = Appstate()

   func receive(state: Appstate) {
      self.appstate = state
   }



   /* MARK: - 1. AUTHENTICATE */

   // This function agregates all the steps required for authentication.

   func authenticate() async {

      appstate.change(to: .loading, for: .auth)

      if (refreshToken != nil) {
         do {
            print("Authorizing with Carris API using refreshToken...")
            try await fetchAuthorization(token: refreshToken!, type: "refresh")
         } catch {
            print("Clearing saved refreshToken...")
            self.refreshToken = nil
            await self.authenticate()
            return
         }
      } else if (apiKey != nil) {
         do {
            print("Authorizing with Carris API using apiKey...")
            try await fetchAuthorization(token: apiKey!, type: "apikey")
         } catch {
            print("Clearing saved apiKey...")
            self.apiKey = nil
            await self.authenticate()
            return
         }
      } else {
         do {
            if (retries > 0) {
               print("Retrieving latest credential from server...")
               try await fetchLatestCredential()
               await self.authenticate()
               retries -= 1
               return
            } else {
               throw Appstate.CarrisAPIError.unauthorized
            }
         } catch {
            appstate.change(to: .error, for: .auth)
            print("Unkown Error")
            return
         }
      }

      saveCredentials()

      appstate.change(to: .idle, for: .auth)

   }


   /* MARK: - 2. FETCH LATEST AVAILABLE CREDENTIAL FROM SERVER */

   // Get latest available Credential from endpoint

   func fetchLatestCredential() async throws {

      var request = URLRequest(url: URL(string: "https://joao.earth/api/geobus/carris_auth")!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "GET"

      let (rawCredential, _) = try await URLSession.shared.data(for: request)
      let decodedCredential = try JSONDecoder().decode(APICredential.self, from: rawCredential)
      DispatchQueue.main.async {
         self.endpoint = decodedCredential.endpoint
         self.apiKey = decodedCredential.token
      }

   }


   /* MARK: - 3. GET VALID AUTH TOKEN AND REFRESH TOKEN FROM AUTHENTICATION API */

   // Get authorization tokens from Carris API

   func fetchAuthorization(token: String, type: String) async throws {

      var request = URLRequest(url: URL(string: "https://" + self.endpoint! + "/gateway/authenticationapi/authorization/sign")!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "POST"

      request.httpBody = try JSONSerialization.data(withJSONObject: ["token": token, "type": type], options: .prettyPrinted)

      let (data, _) = try await URLSession.shared.data(for: request)

      let parsedAuthorization = try JSONDecoder().decode(APIAuthorization.self, from: data)

      DispatchQueue.main.async {
         self.refreshToken = parsedAuthorization.refreshToken
         self.authToken = parsedAuthorization.authorizationToken
      }

   }


}
