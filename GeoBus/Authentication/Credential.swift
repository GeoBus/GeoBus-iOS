//
//  RecentRoutes.swift
//  GeoBus
//
//  Created by João on 19/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import Foundation

struct Credential: Codable {

   var endpoint: String = ""
   var token: String = ""
   var type: String = ""

   func saveToKVS() {
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.set(endpoint, forKey: "credentialEndpoint")
      iCloudKeyStore.set(token, forKey: "credentialToken")
      iCloudKeyStore.set(type, forKey: "credentialType")
      iCloudKeyStore.synchronize()
   }

   func removeFromKVS() {
      let iCloudKeyStore = NSUbiquitousKeyValueStore()
      iCloudKeyStore.removeObject(forKey: "credentialEndpoint")
      iCloudKeyStore.removeObject(forKey: "credentialToken")
      iCloudKeyStore.removeObject(forKey: "credentialType")
      iCloudKeyStore.synchronize()
   }

   mutating func clear() {
      self.endpoint = ""
      self.token = ""
      self.type = ""
      removeFromKVS()
   }

   func isValid() -> Bool {
      return !(endpoint.isEmpty && token.isEmpty && type.isEmpty)
   }

}
