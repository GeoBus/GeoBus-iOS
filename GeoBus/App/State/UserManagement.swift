//
//  UserManagement.swift
//  GeoBus
//
//  Created by João on 25/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct UserManagement {

   func setReturningUser() {
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.set(true, forKey: "isReturningUser")
      iCloudKeyStore.synchronize()
   }


   func isReturningUser() -> Bool {
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.synchronize()
      return iCloudKeyStore.bool(forKey: "isReturningUser")
   }

}
