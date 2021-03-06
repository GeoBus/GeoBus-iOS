//
//  RecentRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Route: Codable, Identifiable, Equatable {
  var id = UUID()
  let number: String
  let name: String
  let kind: String
  var variants: [RouteVariant]

  enum Direction {
    case ascending
    case descending
    case circular
  }

}
