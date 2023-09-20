//
//  themedListRowBG.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import Foundation
import SwiftUI

struct ThemedListRowBGModifier: ViewModifier {
  var enablePadding = false
  var disableBG = false
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
  
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, enablePadding ? 16 : 0)
      .padding(.vertical, enablePadding ? 6 : 0)
      .frame(maxWidth: .infinity, minHeight: 45, alignment: .leading)
      .background(
        disableBG
        ? nil
        : Rectangle()
          .fill(theme.lists.foreground.blurry ? AnyShapeStyle(.bar) : AnyShapeStyle(theme.lists.foreground.color.cs(cs).color()))
          .overlay(!theme.lists.foreground.blurry ? nil : Rectangle().fill(theme.lists.foreground.color.cs(cs).color()))
      )
  }
}

extension View {
  func themedListRowBG(enablePadding: Bool = false, disableBG: Bool = false) -> some View {
    self
      .modifier(ThemedListRowBGModifier(enablePadding: enablePadding, disableBG: disableBG))
  }
}
