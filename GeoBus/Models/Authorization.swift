//
//  RecentRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Authorization: Codable, Identifiable, Equatable {
  let id = UUID()
  let authorizationToken: String
  let refreshToken: String
}
