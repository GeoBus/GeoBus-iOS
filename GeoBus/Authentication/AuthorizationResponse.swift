//
//  AuthorizationResponse.swift
//  GeoBus
//
//  Created by João on 09/09/2022.
//  Copyright © 2022 João. All rights reserved.
//

import Foundation

struct AuthorizationResponse: Decodable {
   let authorizationToken: String
   let refreshToken: String
   let expires: Double
}
