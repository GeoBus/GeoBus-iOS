//
//  AppDelegate.swift
//  GeoBus
//
//  Created by João on 17/04/2020.
//  Copyright © 2020 João. All rights reserved.
//

import UIKit
import PushNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
  let pushNotifications = PushNotifications.shared
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.pushNotifications.start(instanceId: "6d792c0e-5642-475d-9aa1-68188db65b54")
    self.pushNotifications.registerForRemoteNotifications()
    try? self.pushNotifications.addDeviceInterest(interest: "hello")
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  func registerForPushNotifications() {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
      print("Permission granted: \(granted)")
      // 1. Check if permission granted
      guard granted else { return }
      // 2. Attempt registration for remote notifications on the main thread
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    self.pushNotifications.registerDeviceToken(deviceToken)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    self.pushNotifications.handleNotification(userInfo: userInfo)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    // 1. Print out error if PNs registration not successful
    print("Failed to register for remote notifications with error: \(error)")
  }
  
  
}

