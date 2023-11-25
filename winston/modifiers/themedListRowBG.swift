//
//  themedListRowBG.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import Foundation
import SwiftUI
import Shiny

/// A view modifier to apply a themed background to a list row.
struct ThemedListRowBGModifier: ViewModifier {
  /// Whether to enable horizontal and vertical padding.
  var enablePadding = false
  /// Whether to disable the background.
  var disableBG = false
  /// Whether the row is active.
  var active = false
  /// The shiny gradient applied to the background.
  var shiny: Gradient? = nil
  
  /// The theme environment.
  @Environment(\.useTheme) private var theme
  /// The color scheme environment.
  @Environment(\.colorScheme) private var cs
  
  /// Applies the modifier to the content.
  /// - Parameter content: The content to which the modifier is applied.
  /// - Returns: A modified version of the content.
  func body(content: Content) -> some View {
    let isActive = active && IPAD
    return content
      .padding(.horizontal, enablePadding ? 16 : 0)
      .padding(.vertical, enablePadding ? 6 : 0)
      .frame(maxWidth: .infinity, minHeight: 45, alignment: .leading)
      .background(
        disableBG ? nil :
          Rectangle()
          .if(shiny == nil) { content in
            content.fill(theme.lists.foreground.blurry ? AnyShapeStyle(.bar) : AnyShapeStyle(isActive ? .blue : theme.lists.foreground.color.cs(cs).color()))
          }
          .if(shiny != nil) { content in
            content.winstonShiny(shiny)
          }
          .overlay(!theme.lists.foreground.blurry ? nil : Rectangle().fill(isActive ? .blue : theme.lists.foreground.color.cs(cs).color()))
      )
  }
}

extension View {
  /// Applies a themed background to a list row.
  /// - Parameters:
  ///   - enablePadding: Whether to enable horizontal and vertical padding (default is `false`).
  ///   - disableBG: Whether to disable the background (default is `false`).
  ///   - active: Whether the row is active (default is `false`).
  ///   - shiny: The shiny gradient applied to the background (default is `nil`).
  /// - Returns: A modified version of the view with the themed background applied.
  func themedListRowBG(enablePadding: Bool = false, disableBG: Bool = false, active: Bool = false, shiny: Gradient? = nil) -> some View {
    self.modifier(ThemedListRowBGModifier(enablePadding: enablePadding, disableBG: disableBG, active: active, shiny: shiny))
  }
}
