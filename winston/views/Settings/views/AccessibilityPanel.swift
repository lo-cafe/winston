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
  @Default(.arrowDividerColorPalette) var arrowDividerColorPalette
//  @Default(.hapticFeedbackOnLPM) var hapticFeedbackOnLPM
  var body: some View {
      List {
//        Section("Haptics"){
//          Picker("Haptic Feedback Strength -- DOESNT WORK", selection: Binding(get: {
//            forceFeedbackModifiers
//          }, set: { val, _ in
//            forceFeedbackModifiers = val
//          })) {
//            Text("None").tag(ForceFeedbackModifiers.none)
//              .foregroundColor(.red)
//            Text("Light").tag(ForceFeedbackModifiers.light)
//            Text("Medium").tag(ForceFeedbackModifiers.medium)
//            Text("Strong").tag(ForceFeedbackModifiers.strong)
//          }
//          .pickerStyle(.segmented)
//          .frame(maxWidth: .infinity)
//          .labelStyle(.titleOnly)
//          Toggle("Haptics on Low Power Mode -- DOESNT WORK", isOn: $hapticFeedbackOnLPM)
//        }
        
        //These colors are intended to be a global override over any theme and are therefore inside the Accessibility settings
        Section("Color Overrides"){
          ColorPicker("OP Color", selection: $opUsernameColor)
          ColorPicker("Comments Username Color", selection: $commentUsernameColor)
          ColorPicker("Post Accessory Text Color", selection: $postAccessoryColor)
          ColorPicker("Post Accessory Background Color", selection: $postAccessoryBackgroundColor)
          
          Picker("Comments Theme", selection: Binding(get: {
            arrowDividerColorPalette
          }, set: { val, _ in
            arrowDividerColorPalette = val
          })){
            PaletteDisplayItem(palette: ArrowColorPalette.monochrome, name: "Monochrome")
            PaletteDisplayItem(palette: ArrowColorPalette.rainbow, name: "Rainbow")
            PaletteDisplayItem(palette: ArrowColorPalette.ibm, name: "IBM")
            PaletteDisplayItem(palette: ArrowColorPalette.fire, name: "Fire")
            PaletteDisplayItem(palette: ArrowColorPalette.forest, name: "Forest")
            PaletteDisplayItem(palette: ArrowColorPalette.ocean, name: "Ocean")
          }
          .pickerStyle(.inline)
          
          Button{
            opUsernameColor = Color.green
            commentUsernameColor = Color.primary
            postAccessoryColor = Color.primary.opacity(0.5)
            postAccessoryBackgroundColor = Color.blue.opacity(0.2)
            arrowDividerColorPalette = ArrowColorPalette.monochrome

          } label: {
            Label("Revert to Default Colors", systemImage: "")
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
