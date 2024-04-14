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
import CoreHaptics

class AppDelegate: UIResponder, UIApplicationDelegate {
  static private(set) var instance: AppDelegate! = nil
  var supportsHaptics: Bool = false
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    AppDelegate.instance = self
    setAudioToMixWithOthers()
    
    let hapticCapability = CHHapticEngine.capabilitiesForHardware()
    supportsHaptics = hapticCapability.supportsHaptics
    
    return true
  }
    
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    
    if let shortcutItem = options.shortcutItem {
      shortcutItemToProcess = shortcutItem
    }
    
    let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
    sceneConfiguration.delegateClass = CustomSceneDelegate.self
    
    return sceneConfiguration
  }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
  func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    shortcutItemToProcess = shortcutItem
  }
}

public func setAudioToMixWithOthers(_ activateplayback: Bool = false) {
	do {
		let audioSession = AVAudioSession.sharedInstance()
		if (activateplayback == true) {
			try audioSession.setCategory(.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers])
			try audioSession.setActive(true)
		} else {
			try audioSession.setCategory(.ambient, options: [.mixWithOthers])
			try audioSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
		}
	} catch {
		print("Error setting audio session to mix with others")
	}
}
