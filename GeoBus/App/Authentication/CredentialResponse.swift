//
//  CredentialResponse.swift
//  GeoBus
//
//  Created by João on 09/09/2022.
//  Copyright © 2022 João. All rights reserved.
//

import Foundation

struct CredentialResponse: Decodable {
   let endpoint: String
   let token: String
   let type: String
}
