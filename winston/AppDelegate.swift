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

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
    return true
  }
  func applicationDidFinishLaunching(_ application: UIApplication) {
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
}
