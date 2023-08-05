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

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    do {
//      try? AVAudioSession.sharedInstance().setActive(false)
      try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
//      try? AVAudioSession.sharedInstance().setActive(true)
    }
    catch {
      print("Setting category to AVAudioSessionCategoryPlayback failed.")
    }
    return true
  }
//  func applicationDidFinishLaunching(_ application: UIApplication) {
//
//  }
}
