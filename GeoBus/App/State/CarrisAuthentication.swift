import Foundation


/* * */
/* MARK: - CARRIS AUTHENTICATION */
/* A series of self contained steps to authenticate with Carris API. */


final class CarrisAuthentication {
   
   /* * */
   /* MARK: - SECTION 1: SETTINGS */
   /* In this section private constants for update intervals and storage keys are defined. */
   /* ‹maxRetriesBeforeFail› should be more than 3 to make sure any error in the auth server */
   /* is not passed on to the user. */
   
   private let carris_auth_credentialEndpoint = "https://joao.earth/api/geobus/carris_auth"
   private let carris_auth_authorizationEndpoint = "https://gateway.carris.pt/gateway/authenticationapi/authorization/sign"
   
   private let maxRetriesBeforeFail: Int = 3 // Should be 3 or more
   
   private let carris_auth_storageKeyForEndpoint: String = "carris_auth_endpoint"
   private let carris_auth_storageKeyForApiKey: String = "carris_auth_apiKey"
   private let carris_auth_storageKeyForRefreshToken: String = "carris_auth_refreshToken"
   private let carris_auth_storageKeyForAuthToken: String = "carris_auth_AuthToken"
   
   
   
   /* * */
   /* MARK: - SECTION 2: CARRIS API JSON MODEL */
   /* Data model as provided by the API. */
   /* Example request for ‹CarrisAPICredential› is available at https://joao.earth/api/geobus/carris_auth */
   /* Schema for ‹CarrisAPIAuthorization› is available at https://joaodcp.github.io/Carris-API */
   
   struct CarrisAPICredential: Decodable {
      let endpoint: String
      let token: String
      let type: String
   }
   
   struct CarrisAPIAuthorization: Decodable {
      let authorizationToken: String
      let refreshToken: String
      let expires: Double
   }
   
   
   
   /* * */
   /* MARK: - SECTION 3: INTERNAL VARIABLES */
   /* Here are the variables used througout the class. */
   
   public var authToken: String? = nil
   
   private var apiKey: String? = nil
   private var refreshToken: String? = nil
   
   private var currentRetriesLeft: Int = 0
   
   
   
   /* * */
   /* MARK: - SECTION 4: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   static let shared = CarrisAuthentication()
   
   
   
   /* * */
   /* MARK: - SECTION 5: INITIALIZER */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. The init() call is purposefully */
   /* marked private to prevent outsiders from creating another instance of this class. */
   
   private init() {
      
      // Unwrap Carris Auth API Key from Storage
      if let unwrappedCarrisAuthApiKey = UserDefaults.standard.string(forKey: carris_auth_storageKeyForApiKey) {
         self.apiKey = unwrappedCarrisAuthApiKey
      }
      
      // Unwrap Carris Auth Refresh Token from Storage
      if let unwrappedCarrisAuthRefreshToken = UserDefaults.standard.string(forKey: carris_auth_storageKeyForRefreshToken) {
         self.refreshToken = unwrappedCarrisAuthRefreshToken
      }
      
      // Unwrap Carris Auth Authentication Token from Storage
      if let unwrappedCarrisAuthAuthToken = UserDefaults.standard.string(forKey: carris_auth_storageKeyForAuthToken) {
         self.authToken = unwrappedCarrisAuthAuthToken
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 6: AUTHENTICATE */
   /* This function agregates all the steps required for authentication. */
   /* The goal is to have an ‹authToken›. If there is some refreshToken on file, */
   /* then use it to try to request a new short-lived, authToken. If it is invalid, */
   /* then clear the refreshToken variable and re-run the function. On the second run, */
   /* because refreshToken is now nil, try to get an authToken using the apiKey. */
   /* If this second step also fails, then clear the apiKey variable and re-run */
   /* the function one more time. Now, because both refreshToken and apiKey are nil, */
   /* request a fresh credential from the hard-coded credential endpoint and try to */
   /* authenticate again. If it fails again, then retry for as many times as the */
   /* hard-coded setting in this class's first section. After that assume the error. */
   /* If authentication is successful, then save the current values to storage. */
   
   func authenticate() async {
      
      Appstate.shared.change(to: .loading, for: .auth)
      
      // Reset the counter for retries
      currentRetriesLeft = maxRetriesBeforeFail
      
      if (refreshToken != nil) {
         do {
            print("GB: Carris Auth: Authorizing with Carris API using refreshToken...")
            try await fetchAuthorization(token: refreshToken!, type: "refresh")
         } catch {
            print("GB: Carris Auth: Clearing saved refreshToken...")
            refreshToken = nil
            await authenticate()
            return
         }
      } else if (apiKey != nil) {
         do {
            print("GB: Carris Auth: Authorizing with Carris API using apiKey...")
            try await fetchAuthorization(token: apiKey!, type: "apikey")
         } catch {
            print("GB: Carris Auth: Clearing saved apiKey...")
            apiKey = nil
            await authenticate()
            return
         }
      } else {
         do {
            if (currentRetriesLeft > 0) {
               print("GB: Carris Auth: Retrieving latest credential from server...")
               try await fetchLatestCredential()
               await authenticate()
               currentRetriesLeft -= 1
               return
            } else {
               print("GB: Carris Auth: Carris did not accept any known authentication methods.")
               throw Appstate.ModuleError.carris_unauthorized
            }
         } catch {
            Appstate.shared.change(to: .error, for: .auth)
            print("GB: Carris Auth: End of module.")
            return
         }
      }
      
      saveCredentialsToDeviceStorage()
      
      Appstate.shared.change(to: .idle, for: .auth)
      
   }
   
   
   
   /* MARK: - SECTION 7: GET AUTH TOKEN FROM CARRIS API */
   /* This is the function where a valid ‹authToken› is requested to Carris Authentication endpoint. */
   /* Depending on the method of authentication ['apikey', 'refresh'], just perform the request and */
   /* save the result to the respective variables. */
   
   func fetchAuthorization(token: String, type: String) async throws {
      
      var requestCarrisAuthorization = URLRequest(url: URL(string: self.carris_auth_authorizationEndpoint)!)
      requestCarrisAuthorization.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      requestCarrisAuthorization.httpMethod = "POST"
      
      requestCarrisAuthorization.httpBody = try JSONSerialization.data(withJSONObject: ["token": token, "type": type], options: .prettyPrinted)
      
      let (rawDataCarrisAuthorization, _) = try await URLSession.shared.data(for: requestCarrisAuthorization)
      
      let decodedCarrisAuthorization = try JSONDecoder().decode(CarrisAPIAuthorization.self, from: rawDataCarrisAuthorization)
      
      self.refreshToken = decodedCarrisAuthorization.refreshToken
      self.authToken = decodedCarrisAuthorization.authorizationToken
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 8: LATEST CREDENTIAL */
   /* This function retrieves the latest available credential from the endpoint. */
   /* This improves reliability as valid credentials can become invalid at a moment's notice. */
   /* Retrieving from an endpoint allows for a quick server fix and avoids an App Store submission.*/
   
   func fetchLatestCredential() async throws {
      
      var requestCarrisLatestCredential = URLRequest(url: URL(string: self.carris_auth_credentialEndpoint)!)
      requestCarrisLatestCredential.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      requestCarrisLatestCredential.httpMethod = "GET"
      let (rawDataCarrisLatestCredential, _) = try await URLSession.shared.data(for: requestCarrisLatestCredential)
      let decodedCarrisLatestCredential = try JSONDecoder().decode(CarrisAPICredential.self, from: rawDataCarrisLatestCredential)
      
      self.apiKey = decodedCarrisLatestCredential.token
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 9: SAVE CREDENTIALS BACK TO STORAGE */
   /* Save the current credentials to device storage to avoid a new call to the servers. */
   
   func saveCredentialsToDeviceStorage() {
      UserDefaults.standard.set(apiKey, forKey: carris_auth_storageKeyForApiKey)
      UserDefaults.standard.set(refreshToken, forKey: carris_auth_storageKeyForRefreshToken)
      UserDefaults.standard.set(authToken, forKey: carris_auth_storageKeyForAuthToken)
   }
   
   
   
}
