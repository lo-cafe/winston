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
  @Default(.postAccessoryColor) var postAccessoryColor
  @Default(.opUsernameColor) var opUsernameColor
  @Default(.commentUsernameColor) var commentUsernameColor
  @Default(.postAccessoryBackgroundColor) var postAccessoryBackgroundColor
  @Default(.customCommentUsernameColor) var customCommentUsernameColor
  @Default(.customPostAccessoryTextColor) var customPostAccessoryTextColor
//  @Default(.hapticFeedbackOnLPM) var hapticFeedbackOnLPM
  var body: some View {
      List {
        Section("Haptics"){
          VStack{
            Text("Haptic Feedback Strength")
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
          }
        }
        
        //These colors are intended to be a global override over any theme and are therefore inside the Accessibility settings
        Section("Color Overrides"){
          ColorPicker("OP Username Color", selection: $opUsernameColor)
          
          Toggle("Custom Comments Username Color", isOn: $customCommentUsernameColor)
          if customCommentUsernameColor {
            ColorPicker("Comments Username Color", selection: $commentUsernameColor)
          }
          
          Toggle("Custom Post Accessory Text Color", isOn: $customPostAccessoryTextColor)
          if customPostAccessoryTextColor{
            ColorPicker("Post Accessory Text Color", selection: $postAccessoryColor)
          }
          
          ColorPicker("Post Accessory Background Color", selection: $postAccessoryBackgroundColor)
          
          Button{
            opUsernameColor = Color.green
            customCommentUsernameColor = false
            customPostAccessoryTextColor = false
            postAccessoryColor = Color.primary.opacity(0.5)
            postAccessoryBackgroundColor = Color.blue.opacity(0.2)
          } label: {
            Label("Revert to Default Colors", systemImage: "clock.arrow.circlepath")
              .foregroundColor(.red)
          }
        }
        
      }
      .navigationTitle("Accessibility")
      .navigationBarTitleDisplayMode(.inline)
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


struct PaletteDisplayItem: View {
  var palette: ArrowColorPalette
  var name: String
  var body: some View {
    HStack{
      Text(name)
      Spacer()
      PaletteDisplayColor(colors: palette.rawVal)
    }.tag(palette)
  }
}
struct PaletteDisplayColor: View {
  var colors: [Color]
  var body: some View {
    HStack{
      ForEach(colors, id: \.self){ color in
        Rectangle().fill().foregroundStyle(color).clipShape(Circle()).frame(width: 10, height: 10)
      }
    }
  }
}
