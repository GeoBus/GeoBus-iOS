//
//  Auth.swift
//  GeoBus
//
//  Created by João on 09/09/2022.
//  Copyright © 2022 João. All rights reserved.
//

import Foundation

/* MARK: - API Credential */

// Data model as provided by the API.
// Example request is available at https://joao.earth/api/geobus/carris_auth

struct APICredential: Decodable {
   let endpoint: String
   let token: String
   let type: String
}


/* MARK: - API Authorization */

// Data model as provided by the API.
// Schema is available at https://joaodcp.github.io/Carris-API

struct APIAuthorization: Decodable {
   let authorizationToken: String
   let refreshToken: String
   let expires: Double
}
