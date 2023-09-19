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
  @Environment(\.colorScheme) private var cs
  func body(content: Content) -> some View {
    content
      .background(
        Capsule(style: .continuous)
          .fill(.bar.opacity(selectedTheme.general.floatingPanelsBG.blurry ? 1 : 0))
          .shadow(radius: 8, y: 8)
          .overlay(Circle().fill(selectedTheme.general.floatingPanelsBG.color.cs(cs).color()))
      )
      .overlay(
        Capsule(style: .continuous)
          .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
          .padding(.all, 0.5)
      )
  }
}

extension View {
  func floating() -> some View {
    self.modifier(FloatingModifier())
  }
}
//@Environment(\.useTheme) private var selectedTheme
//@Environment(\.colorScheme) private var cs
