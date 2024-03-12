//
//  ShrinkOnTap.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import SwiftUI

struct ShrinkOnTap: ViewModifier {
  @GestureState var isPressed = false
  
  func body(content: Content) -> some View {
    content
      .scaleEffect(isPressed ? 0.95 : 1)
      .simultaneousGesture(
        LongPressGesture(minimumDuration: 1, maximumDistance: 5)
          .updating($isPressed) { val, state, transaction in
            state = val
          }
      )
      .animation(.interpolatingSpring(stiffness: 250, damping: 15), value: isPressed)
  }
}

extension View {
  func shrinkOnTap() -> some View {
    self.modifier(ShrinkOnTap())
  }
}

fileprivate struct ShrinkOnTapButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .buttonStyle(PlainButtonStyle())
      .shrinkOnTap()
  }
}
