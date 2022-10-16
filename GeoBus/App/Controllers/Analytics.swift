//
//  Analytics.swift
//  GeoBus
//
//  Created by João de Vasconcelos on 11/09/2022.
//

import Foundation
import PostHog

/* * */
/* MARK: - ANALYTICS */
/* Wrapper to Posthog. For anyone reading this, this framework was selected */
/* because it was open-source, free, complied with GDPR and allows (some) control */
/* on the amount of data collected, allowing it to be minimized to the fullest extent. */
/* The point is to only record general events, without identifiers, to understand */
/* if calls to the API are working, which routes are selected and how many people are using it. */

final class Analytics {
   
   /* * */
   /* MARK: - SECTION 1: EVENTS */
   /* Defined below are the allowed events to be published to Posthog. */
   
   public enum Event: String {
      
      case App_Session_Start
      case App_Session_Ping
      
      case Routes_Sync_START
      case Routes_Sync_OK
      case Routes_Sync_ERROR
      
      case Routes_Select_FromFavorites
      case Routes_Select_FromTextInput
      case Routes_Select_FromList
      case Routes_Details_RemoveFromFavorites
      case Routes_Details_AddToFavorites
      
      case Stops_Sync_START
      case Stops_Sync_OK
      case Stops_Sync_ERROR
      
      case Stops_Select_FromTextInput
      
      case Location_Status_Allowed
      case Location_Status_Denied
      case Location_Status_DeniedButWillOpenSettingsFromAlert
      
      case Location_Usage_Tap
      case Location_Usage_TapAndHold
      
      case General_Contact_OpenLink
      case General_Share_ShareIntent
      
   }
   
   
   
   /* * */
   /* MARK: - SECTION 2: SHARED INSTANCE */
   /* To allow the same instance of this class to be available accross the whole app, */
   /* we create a Singleton. More info here: https://www.hackingwithswift.com/example-code/language/what-is-a-singleton */
   
   static let shared = Analytics()
   
   
   
   /* * */
   /* MARK: - SECTION 3: INITIALIZATION */
   /* Initialize the framework on init with the set configuration. */
   /* Everything is turned off except for ‹DeviceId› because it is the one */
   /* data point that allows PostHog to aggregate sessions from the same users. */
   /* From what I've read, this is renewed often by Apple and is very difficult to be */
   /* used for tracking when used alone without the other options (which are turned off). */
   
   private let posthog: PHGPostHog?
   
   private init() {
      if let posthogApiKey = Bundle.main.infoDictionary?["POSTHOG_API_KEY"] as? String {
         let configuration = PHGPostHogConfiguration(apiKey: posthogApiKey)
         configuration.shouldUseLocationServices = false
         configuration.flushAt = 1
         configuration.flushInterval = 10
         configuration.maxQueueSize = 1000
         configuration.captureApplicationLifecycleEvents = false
         configuration.shouldUseBluetooth = false
         configuration.recordScreenViews = false
         configuration.captureInAppPurchases = false
         configuration.capturePushNotifications = false
         configuration.captureDeepLinks = false
         configuration.shouldSendDeviceID = true
         PHGPostHog.setup(with: configuration)
         self.posthog = PHGPostHog.shared()
      } else {
         self.posthog = nil
      }
   }
   
   
   
   /* * */
   /* MARK: - SECTION 4: CAPTURE EVENTS */
   /* Captured events can either be only a string or contain additional data. */
   /* Do not capture events if the app is in debug mode (directly run by Xcode). */
   
   func capture(event: Event) {
      if (_isDebugAssertConfiguration()) {
         print("GB Analytics: Captured event '\(event.rawValue)'")
      } else {
         if (self.posthog != nil) {
            self.posthog!.capture(event.rawValue)
         }
      }
   }
   
   func capture(event: Event, properties: [String : Any]) {
      if (_isDebugAssertConfiguration()) {
         print("GB Analytics: Captured event '\(event.rawValue)' with properties '\(properties)'")
      } else {
         if (self.posthog != nil) {
            self.posthog!.capture(event.rawValue, properties: properties)
         }
      }
   }
   
   
}
