import Foundation


/* * */
/* MARK: - CARRIS API WRAPPER */
/* A series of self contained steps to request and authenticate with Carris API. */


final class CarrisAPI {
   
   /* * */
   /* MARK: - SECTION 1: SETTINGS */
   /* In this section private constants for update intervals and storage keys are defined. */
   /* ‹totalAuthenticationAttemptsBeforeFailing› should be more than 3 to make sure any error in the auth server */
   /* is not passed on to the user. */
   
   private let apiEndpoint = "https://gateway.carris.pt/gateway/xtranpassengerapi/api/v2.11/"
   private let authorizationEndpoint = "https://gateway.carris.pt/gateway/authenticationapi/authorization/sign"
   private let credentialEndpoint = "https://joao.earth/api/geobus/carris_auth"
   
   private let storageKeyForEndpoint: String = "carris_endpoint"
   private let storageKeyForApiKey: String = "carris_apiKey"
   private let storageKeyForRefreshToken: String = "carris_refreshToken"
   private let storageKeyForAuthToken: String = "carris_authToken"
   
   
   
   /* * */
   /* MARK: - SECTION 2: THE AUTH TOKEN */
   /* This is the public auth token variable that should be used to authorize requests to the API. */
   
   public var authToken: String? = nil
   
   
   
   /* * */
   /* MARK: - SECTION 3: INTERNAL VARIABLES */
   /* Here are the variables used throughout the class. */
   
   private var apiKey: String? = nil
   private var refreshToken: String? = nil
   
   
   
   /* * */
   /* MARK: - SECTION 4: CARRIS API AUTHENTICATION MODELS */
   /* Data models as provided by the authentication APIs. */
   /* Example request for ‹CarrisAPICredential› is available at https://joao.earth/api/geobus/carris_auth */
   /* Schema for ‹CarrisAPIAuthorization› is available at https://joaodcp.github.io/Carris-API */
   
   private struct CarrisAPICredential: Decodable {
      let endpoint: String?
      let token: String?
      let type: String?
   }
   
   private struct CarrisAPIAuthorization: Decodable {
      let authorizationToken: String?
      let refreshToken: String?
      let expires: Double?
   }
   
   private enum CarrisAPIError: Error {
      case unauthorized
      case unavailable
   }
   
   
   
   /* * */
   /* MARK: - SECTION 5: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   static let shared = CarrisAPI()
   
   
   
   /* * */
   /* MARK: - SECTION 6: INITIALIZER */
   /* When this class is initialized, data stored on the users device must be retrieved */
   /* from UserDefaults to avoid requesting a new update to the APIs. The init() call is purposefully */
   /* marked private to prevent outsiders from creating another instance of this class. */
   
   private init() {
      
      // Unwrap Carris Auth API Key from Storage
      if let unwrappedCarrisAuthApiKey = UserDefaults.standard.string(forKey: storageKeyForApiKey) {
         self.apiKey = unwrappedCarrisAuthApiKey
      }
      
      // Unwrap Carris Auth Refresh Token from Storage
      if let unwrappedCarrisAuthRefreshToken = UserDefaults.standard.string(forKey: storageKeyForRefreshToken) {
         self.refreshToken = unwrappedCarrisAuthRefreshToken
      }
      
      // Unwrap Carris Auth Authentication Token from Storage
      if let unwrappedCarrisAuthAuthToken = UserDefaults.standard.string(forKey: storageKeyForAuthToken) {
         self.authToken = unwrappedCarrisAuthAuthToken
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 7: REQUEST */
   /* This function makes GET requests to Carris API and agregates all the steps required for authentication. */
   /* The process starts by defining flags that serve as logical gates in the authentication flow. */
   /* Next, on the first iteration of the while loop, perform the desired request and await for the response. */
   /* If the response code is 401 Unauthorized, then start the authentication flow. If there is some refresh token */
   /* in memory, then try with that. If not, then try with API key. If that is unavailable, fetch new credentials */
   /* from GeoBus API. In all these steps, set the corresponding flag to ensure that on the next iteration of the */
   /* while loop, the same method is not repeated and the flow gets stuck in an infinite loop. This could be caused */
   /* due to the way authentication in Carris API is implemented: the system returns invalid tokens for an expired key. */
   /* This means that the only way to check if the tokens fetched from the current apiKey are valid is to perform the */
   /* request and look for the response status. Keeping this centralized in one single ‹request()› function */
   /* allows for a lot of code reuse. Also, if the response is not equal to 200 or 401, throw an error immediately. */
   /* If all is well, then return the raw data response to the parent caller. */
   
   public func request(for service: String) async throws -> Data {
      
      var hasAlreadyTryedRefreshToken = false
      var hasAlreadyTryedApiKey = false
      var hasAlreadyTryedLatestCredential = false
      
      while true {
         
         let (data, response) = try await makeGETRequest(url: self.apiEndpoint + service, authenticated: true)
         
         if (response.statusCode == 401) {
            
            print("GeoBus: Carris API: ‹request(for: \(service))› Unauthorized. Fixing...")
            
            if (self.refreshToken != nil && !hasAlreadyTryedRefreshToken) {
               print("GeoBus: Carris API: ‹request(for: \(service))› Trying to use Refresh Token...")
               try await fetchAuthorization(token: self.refreshToken!, type: "refresh")
               hasAlreadyTryedRefreshToken = true
               
            } else if (self.apiKey != nil && !hasAlreadyTryedApiKey) {
               print("GeoBus: Carris API: ‹request(for: \(service))› Trying to use API Key...")
               try await fetchAuthorization(token: self.apiKey!, type: "apikey")
               hasAlreadyTryedApiKey = true
               
            } else if (!hasAlreadyTryedLatestCredential) {
               print("GeoBus: Carris API: ‹request(for: \(service))› Fetching latest credential...")
               try await fetchLatestCredential()
               try await fetchAuthorization(token: self.apiKey!, type: "apikey")
               hasAlreadyTryedLatestCredential = true
               
            } else {
               print("GeoBus: Carris API: ‹request(for: \(service))› Carris API did not accept any known authentication methods.")
               print("********************************************************")
               throw CarrisAPIError.unauthorized
               
            }
            
         } else if (response.statusCode != 200) {
            print("GeoBus: Carris API: Routes: Unknown error. Waiting for manual retry. More info: \(response as Any)")
            print("********************************************************")
            throw CarrisAPIError.unavailable
            
         } else {
            return data
            
         }
         
      }
      
   }
   
   
   
   /* MARK: - SECTION 8: FETCH AUTH TOKEN FROM CARRIS API */
   /* This is the function where a valid ‹authToken› is requested to Carris Authentication endpoint. */
   /* Depending on the method of authentication ['apikey', 'refresh'], just perform the request and */
   /* save the result to the respective variables. */
   
   private func fetchAuthorization(token: String, type: String) async throws {
      
      let (rawDataCarrisAuthorization, _) = try await makePOSTRequest(
         url: self.authorizationEndpoint,
         body: ["token": token, "type": type],
         authenticated: false
      )
      
      let decodedCarrisAuthorization = try JSONDecoder().decode(CarrisAPIAuthorization.self, from: rawDataCarrisAuthorization)
      
      self.refreshToken = decodedCarrisAuthorization.refreshToken
      self.authToken = decodedCarrisAuthorization.authorizationToken
      
      UserDefaults.standard.set(self.refreshToken, forKey: storageKeyForRefreshToken)
      UserDefaults.standard.set(self.authToken, forKey: storageKeyForAuthToken)
      
      print("GeoBus: Carris API: ‹fetchAuthorization(type: \(type))› Done fetching authorization.")
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 9: FETCH LATEST CREDENTIAL */
   /* This function retrieves the latest available credential from the endpoint. */
   /* This improves reliability as valid credentials can become invalid at a moment's notice. */
   /* Retrieving from an endpoint allows for a quick server fix and avoids an App Store submission.*/
   
   private func fetchLatestCredential() async throws {
      
      let (rawDataCarrisLatestCredential, _) = try await makeGETRequest(url: self.credentialEndpoint, authenticated: false)
      let decodedCarrisLatestCredential = try JSONDecoder().decode(CarrisAPICredential.self, from: rawDataCarrisLatestCredential)
      
      self.apiKey = decodedCarrisLatestCredential.token
      
      UserDefaults.standard.set(self.apiKey, forKey: storageKeyForApiKey)
      
      print("GeoBus: Carris API: ‹fetchLatestCredential()› Done fetching latest credential.")
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 10: MAKE REQUEST TO URL */
   /* Convenience function to format, perform and return a GET or POST request to an URL. */
   /* Provide the option to authenticate the request, and for POST the body. */
   
   private func makeGETRequest(url requestURL: String, authenticated: Bool) async throws -> (Data, HTTPURLResponse) {
      
      // Format the request
      var carrisAPIGETRequest = URLRequest(url: URL(string: requestURL)!)
      
      carrisAPIGETRequest.httpMethod = "GET"
      carrisAPIGETRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      carrisAPIGETRequest.addValue("application/json", forHTTPHeaderField: "Accept")
      
      if (authenticated) {
         carrisAPIGETRequest.setValue("Bearer \(self.authToken ?? "-")", forHTTPHeaderField: "Authorization")
      }
      
      // Perform the request
      let (carrisAPIGETRequestRawData, carrisAPIGETRequestRawResponse) = try await URLSession.shared.data(for: carrisAPIGETRequest)
      
      // If cast to HTTPResponse is valid return, else throw an error
      if let carrisAPIGETRequestHTTPResponse = carrisAPIGETRequestRawResponse as? HTTPURLResponse {
         return (carrisAPIGETRequestRawData, carrisAPIGETRequestHTTPResponse)
      } else {
         throw CarrisAPIError.unavailable
      }
      
   }
   
   
   private func makePOSTRequest(url requestURL: String, body requestBody: [String: String], authenticated: Bool) async throws -> (Data, HTTPURLResponse) {
      
      // Format the request
      var carrisAPIPOSTRequest = URLRequest(url: URL(string: self.authorizationEndpoint)!)
      
      carrisAPIPOSTRequest.httpMethod = "POST"
      carrisAPIPOSTRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      carrisAPIPOSTRequest.addValue("application/json", forHTTPHeaderField: "Accept")
      carrisAPIPOSTRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
      
      if (authenticated) {
         carrisAPIPOSTRequest.setValue("Bearer \(self.authToken ?? "-")", forHTTPHeaderField: "Authorization")
      }
      
      // Perform the request
      let (carrisAPIPOSTRequestRawData, carrisAPIPOSTRequestRawResponse) = try await URLSession.shared.data(for: carrisAPIPOSTRequest)
      
      // If cast to HTTPResponse is valid return, else throw an error
      if let carrisAPIPOSTRequestHTTPResponse = carrisAPIPOSTRequestRawResponse as? HTTPURLResponse {
         return (carrisAPIPOSTRequestRawData, carrisAPIPOSTRequestHTTPResponse)
      } else {
         throw CarrisAPIError.unavailable
      }
      
   }
   
   
   
}
