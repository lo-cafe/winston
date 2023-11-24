//
//  AppDelegate.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import Foundation
import UIKit
import SwiftUI
import AVKit
import AVFoundation
import Nuke

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    setAudioToMixWithOthers()
    return true
  }
    
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    setAudioToMixWithOthers()
    
    if let shortcutItem = options.shortcutItem {
      shortcutItemToProcess = shortcutItem
    }
    
    let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
    sceneConfiguration.delegateClass = CustomSceneDelegate.self
    
    return sceneConfiguration
  }
  
  func applicationDidFinishLaunching(_ application: UIApplication) {
    setAudioToMixWithOthers()
    
    let defaultPipeline = ImagePipeline { config in
      config.dataCache = try? DataCache(name: "lo.cafe.winston.datacache")
      let dataLoader: DataLoader = {
        let config = URLSessionConfiguration.default
        config.urlCache = nil
        return DataLoader(configuration: config)
      }()
      config.dataLoader = dataLoader
      config.dataCachePolicy = .storeAll
      config.isUsingPrepareForDisplay = false
      
//      let imgCache = ImageCache(costLimit: Int.max, countLimit: Int.max)
//      imgCache.ttl = nil
//      imgCache.entryCostLimit = 1
//      config.isRateLimiterEnabled = false
    }
    ImagePipeline.shared = defaultPipeline
  }
  
  func setAudioToMixWithOthers() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, options: [.mixWithOthers])
    } catch {
      print("Error setting audio session to mix with others")
    }
  }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    shortcutItemToProcess = shortcutItem
  }
}
