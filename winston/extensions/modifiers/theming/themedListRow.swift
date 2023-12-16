//
//  themedListRow.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import SwiftUI

struct ThemedListRowModifier: ViewModifier {
  var active = false
  var isButton = false
  @State private var pressed = false
  @Environment(\.useTheme) private var theme
  
  func body(content: Content) -> some View {
    content
      .buttonStyle(ButtonPressingProviderStyle(pressed: $pressed, isButton: isButton))
      .listRowBackground(ListRowBackground(theme: theme, active: active, pressed: pressed).equatable())
  }
}

extension View {
  func themedListRow(active: Bool = false, isButton: Bool = false) -> some View {
    self.modifier(ThemedListRowModifier(active: active, isButton: isButton))
  }
}

struct ButtonPressingProviderStyle: ButtonStyle {
  @Binding var pressed: Bool
  var isButton = false
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundStyle(isButton ? Color.accentColor : .primary)
      .onChange(of: configuration.isPressed) { pressed = $0 }
  }
}
