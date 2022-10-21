import Foundation


/* * */
/* MARK: - CARRIS API WRAPPER */
/* A series of self contained steps to request and authenticate with Carris API. */


final class CarrisCommunityAPI {
   
   /* * */
   /* MARK: - SECTION 1: SETTINGS */
   /* In this section private constants for update intervals and storage keys are defined. */
   /* ‹totalAuthenticationAttemptsBeforeFailing› should be more than 3 to make sure any error in the auth server */
   /* is not passed on to the user. */
   
   private let apiEndpoint = "https://api.carril.workers.dev/"
   
   
   
   /* * */
   /* MARK: - SECTION 4: CARRIS API AUTHENTICATION MODELS */
   /* Data models as provided by the authentication APIs. */
   /* Example request for ‹CarrisAPICredential› is available at https://joao.earth/api/geobus/carris_auth */
   /* Schema for ‹CarrisAPIAuthorization› is available at https://joaodcp.github.io/Carris-API */
   
   private enum CarrisCommunityAPIError: Error {
      case unavailable
   }
   
   
   
   /* * */
   /* MARK: - SECTION 5: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   static let shared = CarrisCommunityAPI()
   
   private init() { }
   
   
   
   /* * */
   /* MARK: - SECTION 7: REQUEST */
   /* This function makes GET requests to Carris API and agregates all the steps required for authentication. */
   
   public func request(for service: String) async throws -> Data {
      
      let (data, response) = try await makeGETRequest(url: self.apiEndpoint + service)
      
      if (response.statusCode != 200) {
         print("GeoBus: Carris API: Routes: Unknown error. More info: \(response as Any)")
         print("********************************************************")
         throw CarrisCommunityAPIError.unavailable
      } else {
         return data
      }
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 10: MAKE REQUEST TO URL */
   /* Convenience function to format, perform and return a GET or POST request to an URL. */
   /* Provide the option to authenticate the request, and for POST the body. */
   
   private func makeGETRequest(url requestURL: String) async throws -> (Data, HTTPURLResponse) {
      
      // Format the request
      var carrisAPIGETRequest = URLRequest(url: URL(string: requestURL)!)
      
      carrisAPIGETRequest.httpMethod = "GET"
      carrisAPIGETRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      carrisAPIGETRequest.addValue("application/json", forHTTPHeaderField: "Accept")
      
      // Perform the request
      let (carrisAPIGETRequestRawData, carrisAPIGETRequestRawResponse) = try await URLSession.shared.data(for: carrisAPIGETRequest)
      
      // If cast to HTTPResponse is valid return, else throw an error
      if let carrisAPIGETRequestHTTPResponse = carrisAPIGETRequestRawResponse as? HTTPURLResponse {
         return (carrisAPIGETRequestRawData, carrisAPIGETRequestHTTPResponse)
      } else {
         throw CarrisCommunityAPIError.unavailable
      }
      
   }
   
   
   
}
