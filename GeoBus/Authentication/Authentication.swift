//
//  AvailableRoutes.swift
//  GeoBus
//
//  Created by João on 20/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

class Authentication: ObservableObject {

   /* MARK: - Overview */

   // 1. RETRIEVE SAVED CREDENTIAL FROM STORAGE
   //    Check if there is already a saved Credential in iCloud KVS.
   //    If found, use this. If not, retrieve a new one.

   // 2. FETCH LATEST AVAILABLE CREDENTIAL FROM SERVER
   //    This improves reliability as valid credentials can become
   //    invalid at a moment's notice. Retrieving from an endpoint
   //    allows for a quick server fix and avoids an App Store submission.

   // 3. GET VALID AUTH TOKEN AND REFRESH TOKEN FROM AUTHENTICATION API
   //    Fetch the Carris Authentication API to retrieve a valid authToken
   //    and refreshToken to process further requests.

   /* * */


   /* MARK: - Variables */

   private var retries = 3
   private var credential = Credential()
   private var authorization = Authorization()

   @Published var authToken = ""

   /* * */


   /* MARK: - Errors */

   enum AuthenticationError: Error {
      case InvalidCredentialFromKVS
      case CredentialServerFetchError
      case CarrisAPIUnavailable
      case CarrisAPIUnauthorizedAccess
   }

   /* * */


   /* MARK: - Init */

   init() {
      // Initiate authentication on init to save time
      authenticate()
   }

   /* * */


   /* MARK: - 0. Authenticate */

   // This function agregates all the steps required for authentication

   func authenticate() {

      if retries > 0 {

         retries -= 1

         Task {

            // 1. CREDENTIAL

            do {
               // 1. If necessary,
               if !(self.credential.isValid()) {
                  // 1.A. Retrieve Credential from KVS
                  print("Retrieving Credential from iCloud KVS...")
                  self.credential = try retrieveCredentialFromKVS()
               }

            } catch AuthenticationError.InvalidCredentialFromKVS {
               do {
                  // 1.B. Retrieve Credential from Server
                  print("KVS has no valid Credential. Fetching new from server...")
                  self.credential = try await fetchLatestCredential()
                  self.credential.saveToKVS()

               } catch AuthenticationError.CredentialServerFetchError {
                  // 1.C. Impossible to get valid credential
                  print("Credential server is unavailable.")
                  return
               }
            }


            // 2. AUTHORIZATION

            do {
               // 2. Get authorization_token from Carris Auth API
               print("Authorizing with Carris API...")
               self.authorization = try await fetchAuthorization()

            } catch {
               // 2.2. The request was OK but the credential is not accepted
               print("Available credential is invalid. Clearing everything...")
               print(credential.token)
               self.credential.clear()
               self.authorization.clear()
               self.authenticate()
               return
            }

         }

      }

   }

   /* * */


   /* MARK: - 1. RETRIEVE SAVED CREDENTIAL FROM STORAGE */

   // Retrieve previously saved Credential from iCloud KVS Storage

   func retrieveCredentialFromKVS() throws -> Credential {
      // Syncronize with iCloud KVS
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.synchronize()

      // Retrieve from KVS and throw if invalid
      guard let retrievedEndpoint = iCloudKeyStore.string(forKey: "credentialEndpoint") else {
         throw AuthenticationError.InvalidCredentialFromKVS
      }
      guard let retrievedToken = iCloudKeyStore.string(forKey: "credentialToken") else {
         throw AuthenticationError.InvalidCredentialFromKVS
      }
      guard let retrievedType = iCloudKeyStore.string(forKey: "credentialType") else {
         throw AuthenticationError.InvalidCredentialFromKVS
      }

      // Return retrieved Credential to caller
      return Credential(
         endpoint: retrievedEndpoint,
         token: retrievedToken,
         type: retrievedType
      )
   }

   /* * */


   /* MARK: - 2. FETCH LATEST AVAILABLE CREDENTIAL FROM SERVER */

   // Get latest available Credential from endpoint

   func fetchLatestCredential() async throws -> Credential {

      // Setup the request
      var request = URLRequest(url: URL(string: "https://joao.earth/api/geobus/carris_auth")!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "GET"

      do {
         let (data, _) = try await URLSession.shared.data(for: request)
         let decodedCredential = try JSONDecoder().decode(Credential.self, from: data)
         return Credential(
            endpoint: decodedCredential.endpoint,
            token: decodedCredential.token,
            type: decodedCredential.type
         )
      } catch {
         print("Error: \(error)")
         throw AuthenticationError.CredentialServerFetchError
      }

   }

   /* * */


   /* MARK: - 3. GET VALID AUTH TOKEN AND REFRESH TOKEN FROM AUTHENTICATION API */

   // Get authorization tokens from Carris API

   func fetchAuthorization() async throws -> Authorization {

      // Setup the request
      var request = URLRequest(url: URL(string: "https://" + self.credential.endpoint + "/gateway/authenticationapi/authorization/sign")!)
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.httpMethod = "POST"


      // Define a new variable
      var parameters: [String: Any]

      if (self.authorization.isValid()) {
         // Use Refresh Token
         parameters = ["token": self.authorization.refreshToken, "type": "refresh"]
      } else {
         // Use Credential
         parameters = ["token": self.credential.token, "type": self.credential.type]
      }

      // Serialize parameters into JSON
      request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

      // Perform request
      let (data, response) = try await URLSession.shared.data(for: request)

      // If response is not OK
      let httpResponse = response as? HTTPURLResponse

      if httpResponse?.statusCode == 400 {
         // Retry because the refresh code might be expired
         print("Request failed with status 400 - Unauthorized.")
         throw AuthenticationError.CarrisAPIUnauthorizedAccess
      } else if httpResponse?.statusCode != 200 {
         print("Request failed for unknown reason.")
         throw AuthenticationError.CarrisAPIUnavailable
      }

      let parsedAuthorization = try JSONDecoder().decode(Authorization.self, from: data)
      self.authToken = parsedAuthorization.authorizationToken

      return parsedAuthorization

   }

   /* * */


}
