//
//  hapticFeedbackModifier.swift
//  winston
//
//  Created by Daniel Inama on 13/08/23.
//

import Foundation
import Defaults
import AllujaHaptics
//extension SimpleHapticGenerator {
//  ///Fire a haptic feedback event while also repsecting Winstons accessibility setting with the given intensity and sharpness (0-1).
//  func accessFire(intensity: Float = 0.75, sharpness: Float = 0.75) throws{
//    @Default(.hapticFeedbackOnLPM) var hapticFeedbackOnLPM
//    @Default(.forceFeedbackModifiers) var forceFeedbackModifier
//    let lpm = ProcessInfo.processInfo.isLowPowerModeEnabled
//    if hapticFeedbackOnLPM{
//        try? self.fire(intensity: intensity * forceFeedbackModifier.id,sharpness: sharpness)
//    } else {
//      if !lpm {
//        try? self.fire(intensity: intensity * forceFeedbackModifier.id,sharpness: sharpness)
//      }
//    }
//  }
//}

public struct WinstonHapticPatterns{
  init() {
  }
  
  static let click = try? Haptics.generateHaptic(fromComponents: [.impact(.custom(Float(0.6 * Defaults[.forceFeedbackModifiers].rawVal)), .sharp)], generatePlayer: true)
  static let clickHard = try? Haptics.generateHaptic(fromComponents: [.impact(.custom(Float(1 * Defaults[.forceFeedbackModifiers].rawVal)), .sharp)], generatePlayer: true)
  static let doubleClick = try? Haptics.generateHaptic(fromComponents: [.impact(.custom(Float(0.6 * Defaults[.forceFeedbackModifiers].rawVal)), .sharp), .impact(.hard, .sharp)], generatePlayer: true)
  static let destructiveClick = try? Haptics.generateHaptic(fromComponents: [.impact(.custom(Float(0.6 * Defaults[.forceFeedbackModifiers].rawVal)), .sharp), .impact(.hard, .dull)], generatePlayer: true)
  static let success = try? Haptics.generateHaptic(fromComponents: [.delay(0.2), .impact(.custom(Float(1 * Defaults[.forceFeedbackModifiers].rawVal)), .sharp), .impact(.hard, .sharp), .impact(.hard, .sharp)], generatePlayer: true)
  static let fail = try? Haptics.generateHaptic(fromComponents: [.delay(0.2), .impact(.custom(Float(1 * Defaults[.forceFeedbackModifiers].rawVal)), .sharp), .impact(.hard, .sharp), .impact(.hard, .dull)], generatePlayer: true)
}
