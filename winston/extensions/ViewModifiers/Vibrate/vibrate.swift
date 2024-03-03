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
  var disabled: Bool
  
  init(_ vibration: Vibration, trigger: T, disabled: Bool = false) {
    self.vibration = vibration
    self.value = trigger
    self.disabled = disabled
  }
  
  @State private var hapticHolder = HapticHolder()
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
        guard !disabled else { return }
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
        case .background, .inactive: hapticHolder.stopEngine()
        @unknown default: break
        }
      }
  }
  
  enum Vibration {
    case continuous(sharpness: Double, intensity: Double)
    case transient(sharpness: Double, intensity: Double)
  }
}

extension View {
  func vibrate<T: Equatable>(_ vibration: VibrateModifier<T>.Vibration, trigger: T, disabled: Bool = false) -> some View {
    self
      .modifier(VibrateModifier(vibration, trigger: trigger, disabled: disabled))
  }
}
