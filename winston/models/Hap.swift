//
//  Haptico.swift
//  winston
//
//  Created by Igor Marcossi on 16/12/23.
//

import SwiftUI
import CoreHaptics

class Hap {
  static var shared = Hap()
  
  private var engine: CHHapticEngine? = nil
  private var continuousHapticTimer: Timer? = nil
  private var engineNeedsStart = true
  private var continuousPlayer: CHHapticAdvancedPatternPlayer? = nil
  private lazy var supportsHaptics: Bool = {
    return AppDelegate.instance?.supportsHaptics ?? false
  }()
  private let initialIntensity: Float = 1
  private let initialSharpness: Float = 0
  
  private init() {
    createAndStartHapticEngine()
    createContinuousHapticPlayer()
    
    NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  deinit {
    self.stopEngine()
  }
  
  func startContinuous() {
    guard supportsHaptics, let continuousPlayer = self.continuousPlayer else { return }
    
    do {
      try continuousPlayer.start(atTime: CHHapticTimeImmediate)
    } catch let error {
      print("Error starting the continuous haptic player: \(error)")
    }
    
  }
  
  func stopContinuous() {
    guard supportsHaptics, let continuousPlayer = self.continuousPlayer else { return }
    
    do {
      try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
    } catch let error {
      print("Error stopping the continuous haptic player: \(error)")
    }
    
  }
  
  func updateContinuous(intensity: Float, sharpness: Float) {
    guard supportsHaptics, let continuousPlayer = self.continuousPlayer else { return }
    
//    if continuousHapticTimer == nil {
//      self.startPlayingContinuousHaptics()
//    }
    
    let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0)
    let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: sharpness, relativeTime: 0)
    
    do {
      try continuousPlayer.sendParameters([intensityParameter, sharpnessParameter], atTime: 0)
    } catch let error {
      print("Dynamic Parameter Error: \(error)")
    }
    
//    setupTimer()
    
//    func setupTimer() {
//      continuousHapticTimer?.invalidate()
//      continuousHapticTimer = .init(timeInterval: Date().timeIntervalSince1970 + 0.5, repeats: false, block: { _ in
//        self.continuousHapticTimer = nil
//        self.stopPlayingContinuousHaptics()
//      })
//    }
  }
  
  func play(intensity: Float, sharpness: Float) {
    
    guard supportsHaptics, let engine = self.engine else { return }
    
    let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
    let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)
    
    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: CHHapticTimeImmediate)
    } catch let error {
      print("Error creating a haptic transient pattern: \(error)")
    }
  }
  
  func stopEngine() {
    guard self.supportsHaptics, let engine = self.engine else { return }
    
    engine.stop(completionHandler: { error in
      if let error = error {
        print("Haptic Engine Shutdown Error: \(error)")
        return
      }
      self.engineNeedsStart = true
    })
  }
  
  func startEngine() {
    guard self.supportsHaptics, let engine = self.engine else { return }
    
    engine.playsHapticsOnly = true
    engine.start(completionHandler: { error in
      if let error = error {
        print("Haptic Engine Startup Error: \(error)")
        return
      }
      self.engineNeedsStart = false
    })
  }
  
  func createAndStartHapticEngine() {
    guard engineNeedsStart else { return }
    do {
      engine = try CHHapticEngine()
    } catch let error {
      print("Engine Creation Error: \(error)")
    }
    guard let engine = engine else { return }

    engine.playsHapticsOnly = true
    
    // The stopped handler alerts you of engine stoppage.
    engine.stoppedHandler = { reason in
      print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
      switch reason {
      case .audioSessionInterrupt:
        print("Audio session interrupt")
      case .applicationSuspended:
        print("Application suspended")
      case .idleTimeout:
        print("Idle timeout")
      case .systemError:
        print("System error")
      case .notifyWhenFinished:
        print("Playback finished")
      case .gameControllerDisconnect:
        print("Controller disconnected.")
      case .engineDestroyed:
        print("Engine destroyed.")
      @unknown default:
        print("Unknown error")
      }
    }
    
    engine.resetHandler = {
      print("Reset Handler: Restarting the engine.")
      do {
        try engine.start()
        engine.playsHapticsOnly = true
        self.engineNeedsStart = false
        self.createContinuousHapticPlayer()
      } catch {
        print("Failed to start the engine")
      }
    }
    
    startEngine()
  }
  
  @objc func appDidBecomeActive() {
    startEngine()
  }
  
  func createContinuousHapticPlayer() {
    guard let engine = engine else { return }
    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: initialIntensity)
    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: initialSharpness)
    
    let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 100)
    
    do {
      let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
      continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
    } catch let error {
      print("Pattern Player Creation Error: \(error)")
    }
  }
  
}
