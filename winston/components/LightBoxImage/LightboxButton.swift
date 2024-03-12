//
//  LightboxButton.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI

struct LightBoxButton: View {
  @State private var pressed = false
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
      .onTapGesture {
        if !disabled {
          withAnimation(.interpolatingSpring(stiffness: 250, damping: 15)) { pressed = true }
          action?()
          pressed.toggle()
        }
      }
      .transition(.scaleAndBlur)
      .id(icon)
  }
}
