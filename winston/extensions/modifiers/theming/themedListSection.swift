//
//  themedListSection.swift
//  winston
//
//  Created by Igor Marcossi on 06/12/23.
//

import SwiftUI
import Foundation
import SwiftUI
import Shiny

/// A view modifier to apply a themed background to a list row.
struct ThemedListSectionModifier: ViewModifier {
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
    
  func body(content: Content) -> some View {
    content
      .listRowBackground(ListRowBackground(theme: theme).equatable())
      .listRowSeparatorTint(theme.lists.dividersColors.cs(cs).color())
//      .id(cs)
  }
}

extension View {
  func themedListSection() -> some View {
    self.modifier(ThemedListSectionModifier())
  }
}
