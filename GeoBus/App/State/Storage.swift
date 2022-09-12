//
//  VehicleStores.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 10/09/2022.
//

import Boutique

extension Store where Item == Route {
   static let routesStore = Store<Route>(
      storage: SQLiteStorageEngine.default(appendingPath: "Routes")
   )
}
