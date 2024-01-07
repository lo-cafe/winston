//
//  themedListRowLikeBG.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import Foundation
import SwiftUI
import Shiny

/// A view modifier to apply a themed background to a list row.
struct ThemedListRowLikeBGModifier: ViewModifier {
  var enablePadding = false
  var disableBG = false
  var active = false
  var pressed = false
  var shiny: Gradient? = nil
  var opacity: Double = 1
  
  /// The theme environment.
  @Environment(\.useTheme) private var theme
  
  /// Applies the modifier to the content.
  /// - Parameter content: The content to which the modifier is applied.
  /// - Returns: A modified version of the content.
  func body(content: Content) -> some View {
    let isActive = active && IPAD
    return content
      .padding(.horizontal, enablePadding ? 16 : 0)
      .padding(.vertical, enablePadding ? 8 : 0)
      .frame(maxWidth: .infinity, minHeight: 45, alignment: .leading)
      .background(disableBG ? nil : ThemedForegroundBG(theme: theme.lists.foreground, active: isActive, pressed: pressed, shiny: shiny).equatable().opacity(opacity))
  }
}

extension View {
  /// Applies a themed background to a list row.
  /// - Parameters:
  ///   - enablePadding: Whether to enable horizontal and vertical padding (default is `false`).
  ///   - disableBG: Whether to disable the background (default is `false`).
  ///   - active: Whether the row is active (default is `false`).
  ///   - shiny: The shiny gradient applied to the background (default is `nil`).
  ///   - opacity: The opacity of the background (default is `1`).
  /// - Returns: A modified version of the view with the themed background applied.
  func themedListRowLikeBG(enablePadding: Bool = false, disableBG: Bool = false, active: Bool = false, pressed: Bool = false, shiny: Gradient? = nil, opacity: Double = 1) -> some View {
    self.modifier(ThemedListRowLikeBGModifier(enablePadding: enablePadding, disableBG: disableBG, active: active, pressed: pressed, shiny: shiny, opacity: opacity))
  }
}
