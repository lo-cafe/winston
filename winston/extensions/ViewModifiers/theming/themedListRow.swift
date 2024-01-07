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
      .listRowBackground(ThemedForegroundBG(theme: theme.lists.foreground, active: active, pressed: pressed).equatable())
  }
}

extension View {
  func themedListRow(active: Bool = false, isButton: Bool = false) -> some View {
    self.modifier(ThemedListRowModifier(active: active, isButton: isButton))
  }
}
