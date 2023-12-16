//
//  BigInput.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import SwiftUI

struct BigInput: View {
  var l: String
  @Binding var t: String
  @FocusState var focused: Bool
  var placeholder: String? = nil
  @Environment(\.colorScheme) private var cs
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(l.uppercased()).fontSize(13, .semibold).padding(.horizontal, 12).opacity(0.5)
      TextField(l, text: $t, prompt: placeholder == nil ? nil : Text(placeholder!))
        .focused($focused)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.none)
        .fontSize(16, .medium, design: .monospaced)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
          RR(16, Color("acceptableBlack"))
            .brightness(focused ? cs == .dark ? 0.1 : 0.1 : 0)
            .shadow(color: .black.opacity(focused ? cs == .dark ? 0.25 : 0.15 : 0), radius: focused ? 12 : 0, y: focused ? 6 : 0)
            .animation(.easeOut.speed(2.5), value: focused)
            .onTapGesture {
              focused = true
            }
        )
    }
  }
}
