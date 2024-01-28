//
//  floating.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import Foundation
import SwiftUI
import Defaults

struct FloatingModifier: ViewModifier {
  @Environment(\.useTheme) private var selectedTheme
  func body(content: Content) -> some View {
    content
      .background(ThemedForegroundRawBG(shape: Capsule(style: .continuous), theme: selectedTheme.general.floatingPanelsBG, shadowStyle: .drop(color: .black.opacity(0.33), radius: 16, x: 0, y: 12)).allowsHitTesting(false))
      .overlay {
        Capsule(style: .continuous)
          .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
          .padding(.all, 0.5)
      }
      .contentShape(Capsule(style: .continuous))
  }
}

extension View {
  func floating() -> some View {
    self.modifier(FloatingModifier())
  }
}

