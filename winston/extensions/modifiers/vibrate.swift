//
//  vibrate.swift
//  winston
//
//  Created by Igor Marcossi on 29/11/23.
//

import SwiftUI
import CoreHaptics



struct VibrateModifier<T: Equatable>: ViewModifier {
  
  var vibration: Vibration
  var value: T
  
  init(_ vibration: Vibration, trigger: T) {
    self.vibration = vibration
    self.value = trigger
  }

  @StateObject private var hapticHolder = HapticHolder()
  @Environment(\.scenePhase) private var scenePhase
  func body(content: Content) -> some View {
    content
      .onAppear {
        hapticHolder.createAndStartHapticEngine()
        hapticHolder.createContinuousHapticPlayer()
      }
      .onDisappear {
        hapticHolder.stopEngine()
      }
      .onChange(of: value) { _ in
        switch vibration {
        case .continuous(let sharpness, let intensity):
          hapticHolder.playHapticContinuous(intensity: Float(intensity), sharpness: Float(sharpness))
        case .transient(let sharpness, let intensity):
          hapticHolder.playHapticTransient(intensity: Float(intensity), sharpness: Float(sharpness))
        }
      }
      .onChange(of: scenePhase) {
        switch $0 {
        case .active: hapticHolder.startEngine()
        case .background, .inactive: hapticHolder.startEngine()
        @unknown default: break
        }
      }
  }
  
  enum Vibration {
    case continuous(sharpness: Double, intensity: Double)
    case transient(sharpness: Double, intensity: Double)
  }
  
  class HapticHolder: ObservableObject {
    private var engine: CHHapticEngine? = nil
    private var continuousHapticTimer: Timer? = nil
    private var engineNeedsStart = true
    private var continuousPlayer: CHHapticAdvancedPatternPlayer? = nil
    private lazy var supportsHaptics: Bool = {
      return AppDelegate.instance?.supportsHaptics ?? false
    }()
    private let initialIntensity: Float = 1.0
    private let initialSharpness: Float = 0.5
    
    private func startPlayingContinuousHaptics() {
      guard supportsHaptics, let continuousPlayer = self.continuousPlayer else { return }
      
      do {
        try continuousPlayer.start(atTime: CHHapticTimeImmediate)
      } catch let error {
        print("Error starting the continuous haptic player: \(error)")
      }
      
    }
    
    private func stopPlayingContinuousHaptics() {
      guard supportsHaptics, let continuousPlayer = self.continuousPlayer else { return }
      
      do {
        try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
      } catch let error {
        print("Error stopping the continuous haptic player: \(error)")
      }
      
    }
    
    func playHapticContinuous(intensity: Float, sharpness: Float) {
      guard supportsHaptics, let continuousPlayer = self.continuousPlayer else { return }

        let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity * initialIntensity, relativeTime: 0)
        let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: sharpness * initialSharpness, relativeTime: 0)
        
        do {
          try continuousPlayer.sendParameters([intensityParameter, sharpnessParameter], atTime: 0)
        } catch let error {
          print("Dynamic Parameter Error: \(error)")
      }
      
      func setupTimer() {
        continuousHapticTimer?.invalidate()
        continuousHapticTimer = .init(timeInterval: Date().timeIntervalSince1970 + 0.3, repeats: false, block: { _ in
          self.continuousHapticTimer = nil
          self.stopPlayingContinuousHaptics()
        })
      }
      
//      print("rkwrm kwmre")
      if continuousHapticTimer == nil {
        self.startPlayingContinuousHaptics()
      }
      setupTimer()
    }
      
    func playHapticTransient(intensity: Float, sharpness: Float) {
      guard supportsHaptics, let engine = self.engine else { return }
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
      
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            // Create a player to play the haptic pattern.
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate) // Play now.
        } catch let error {
            print("Error creating a haptic transient pattern: \(error)")
        }
    }
    
    func stopEngine() {
      guard self.supportsHaptics, let engine = self.engine else {
        return
      }
      engine.stop(completionHandler: { error in
        if let error = error {
          print("Haptic Engine Shutdown Error: \(error)")
          return
        }
        self.engineNeedsStart = true
      })
    }
    
    func startEngine() {
      guard self.supportsHaptics, let engine = self.engine else {
        return
      }
      engine.start(completionHandler: { error in
        if let error = error {
          print("Haptic Engine Startup Error: \(error)")
          return
        }
        self.engineNeedsStart = false
      })
    }
    
    func createAndStartHapticEngine() {
      do {
        engine = try CHHapticEngine()
      } catch let error {
        fatalError("Engine Creation Error: \(error)")
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
          self.engineNeedsStart = false
          self.createContinuousHapticPlayer()
        } catch {
          print("Failed to start the engine")
        }
      }
      
      do {
        try engine.start()
      } catch {
        print("Failed to start the engine: \(error)")
      }
    }
    
    func createContinuousHapticPlayer() {
      guard let engine = engine else { return }
      let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: initialIntensity)
      let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: initialSharpness)
      
      let continuousEvent = CHHapticEvent(eventType: .hapticContinuous,
                                          parameters: [intensity, sharpness],
                                          relativeTime: 0,
                                          duration: 100)
      
      do {
        let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
        
        continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
        
      } catch let error {
        print("Pattern Player Creation Error: \(error)")
      }
    }
    
    func playHapticTransient(time: TimeInterval, intensity: Float, sharpness: Float) {
      
      guard supportsHaptics, let engine = engine else { return }
      
      let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
      
      let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
      
      let event = CHHapticEvent(eventType: .hapticTransient,
                                parameters: [intensityParameter, sharpnessParameter],
                                relativeTime: 0)
      
      do {
        let pattern = try CHHapticPattern(events: [event], parameters: [])
        
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate) // Play now.
      } catch let error {
        print("Error creating a haptic transient pattern: \(error)")
      }
    }
  }
}





extension View {
  func vibrate<T: Equatable>(_ vibration: VibrateModifier<T>.Vibration, trigger: T) -> some View {
    self
      .modifier(VibrateModifier(vibration, trigger: trigger))
  }
}
