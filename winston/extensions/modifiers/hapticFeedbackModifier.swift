//
//  hapticFeedbackModifier.swift
//  winston
//
//  Created by Daniel Inama on 13/08/23.
//

//import Foundation
//import Defaults

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
