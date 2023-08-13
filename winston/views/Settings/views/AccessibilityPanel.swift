//
//  AccessibilityPanel.swift
//  winston
//
//  Created by Daniel Inama on 13/08/23.
//

import SwiftUI
import Defaults
struct AccessibilityPanel: View {
  @Default(.forceFeedbackModifiers) var forceFeedbackModifiers
  @Default(.hapticFeedbackOnLPM) var hapticFeedbackOnLPM
    var body: some View {
      List{
        Section("Haptics"){
          Picker("Haptic Feedback Strength", selection: Binding(get: {
            forceFeedbackModifiers
          }, set: { val, _ in
            forceFeedbackModifiers = val
          })) {
            Text("None").tag(ForceFeedbackModifiers.none)
              .foregroundColor(.red)
            Text("Light").tag(ForceFeedbackModifiers.light)
            Text("Medium").tag(ForceFeedbackModifiers.medium)
            Text("Strong").tag(ForceFeedbackModifiers.strong)
          }
          .pickerStyle(.segmented)
          .frame(maxWidth: .infinity)
          .labelStyle(.titleOnly)
          Toggle("Haptics on Low Power Mode", isOn: $hapticFeedbackOnLPM)
        }
      }
      Spacer()
    }
}

/// Enum of force feedback modifiers for accessibility
enum ForceFeedbackModifiers:  Codable, CaseIterable, Identifiable, Defaults.Serializable{
  var id: Float {
    self.rawVal
  }
  
  case none
  case light
  case medium
  case strong
  
  var rawVal: Float {
    switch self{
    case .none:
      return 0.0
    case .light:
      return 0.5
    case .medium:
      return 1.0
    case .strong:
      return 2.0
    }
  }
}
