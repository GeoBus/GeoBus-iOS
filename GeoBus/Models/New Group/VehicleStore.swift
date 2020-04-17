//
//  VehicleStore.swift
//  GeoBus
//
//  Created by João on 16/04/2020.
//  Copyright © 2020 João de Vasconcelos. All rights reserved.
//

import Combine

class VehicleStore: ObservableObject {
  @Published var vehicles: [Vehicle] = []
}
