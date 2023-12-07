//
//  Shiny.swift
//  winston
//
//  Created by daniel on 23/11/23.
//

import SwiftUI
import Shiny
import Defaults

/// A view modifier to apply the Shiny effect with a specified gradient.
struct ShinyModifier: ViewModifier {
  /// The gradient used for the Shiny effect.
  var shiny: Gradient?
  @Environment(\.colorScheme) private var cs
  @Environment(\.useTheme) private var theme

  /// Applies the Shiny effect to the content if the corresponding user preference is enabled.
  /// - Parameter content: The content to which the modifier is applied.
  /// - Returns: A modified version of the content with the Shiny effect applied if enabled.
  func body(content: Content) -> some View {
    content
      .if(Defaults[.shinyTextAndButtons]) { content in
        content.shiny(shiny ?? Gradient(colors: createPaletteFromColors(colors: [theme.general.accentColor.cs(cs).color().opacity(0.1), ], opacity: 1) + [theme.lists.foreground.color.cs(cs).color()]))
      }
      .if(!Defaults[.shinyTextAndButtons]){ content in
        content.foregroundColor(shiny?.stops.first?.color ?? theme.posts.bodyText.color.cs(cs).color())
      }
  }
}

extension View {
  /// Applies the Shiny effect to the view with a specified gradient.
  /// - Parameter shiny: The gradient used for the Shiny effect.
  /// - Returns: A modified version of the view with the Shiny effect applied.
  func winstonShiny(_ shiny: Gradient? = nil) -> some View {
    self.modifier(ShinyModifier(shiny: shiny))
  }
}
