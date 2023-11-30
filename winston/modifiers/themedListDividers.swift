//
//  themedListDividers.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import Foundation
import SwiftUI

struct ThemedListDividersModifier: ViewModifier {
  var enablePadding: Bool? = false
  var active = false
  @Environment(\.useTheme) private var theme
  @Environment(\.colorScheme) private var cs
  
  func body(content: Content) -> some View {
    let isActive = active && IPAD
    content
      .listRowBackground(
          Rectangle()
            .fill(theme.lists.foreground.blurry ? AnyShapeStyle(.bar) : AnyShapeStyle(isActive ? .blue : theme.lists.foreground.color.cs(cs).color()))
          .overlay(!theme.lists.foreground.blurry ? nil : Rectangle().fill(isActive ? .blue : theme.lists.foreground.color.cs(cs).color()))
      )
      .listRowInsets(enablePadding == nil ? nil : EdgeInsets(top: enablePadding! ? 8 : 0, leading: enablePadding! ? 16 : 0, bottom: enablePadding! ? 8 : 0, trailing: enablePadding! ? 16 : 0))
      .listRowSeparatorTint(theme.lists.dividersColors.cs(cs).color())
      .id(cs)
  }
}

extension View {
  func themedListDividers(enablePadding: Bool? = false) -> some View {
    self
      .modifier(ThemedListDividersModifier(enablePadding: enablePadding))
  }
}
