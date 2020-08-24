//
//  RecentRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Endpoint: Codable, Identifiable, Equatable {
  let id = UUID()
  let endpoint: String
  let token: String
}
