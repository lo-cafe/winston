//
//  LightboxButton.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI

struct LightBoxButton: View {
  @GestureState var pressed = false
  var icon: String
  var action: (()->())?
  var disabled = false
  var body: some View {
    Image(systemName: icon)
      .fontSize(20)
      .frame(width: 56, height: 56)
      .background(Circle().fill(.secondary.opacity(pressed ? 0.15 : 0)))
      .contentShape(Circle())
      .scaleEffect(pressed ? 0.95 : 1)
      .if(!disabled) {
        $0.onTapGesture {
          action?()
        }
        .simultaneousGesture(
          LongPressGesture(minimumDuration: 1)
            .updating($pressed, body: { newPressed, state, transaction in
              transaction.animation = .interpolatingSpring(stiffness: 250, damping: 15)
              state = newPressed
            })
        )
      }
      .transition(.scaleAndBlur)
      .id(icon)
  }
}
