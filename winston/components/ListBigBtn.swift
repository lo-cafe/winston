//
//  ListBigBtn.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import SwiftUI
import Shiny
import Defaults

/// A button with an icon, label, and optional shiny gradient, used in a list.
struct ListBigBtn: View {
  /// The binding for the selected subreddit.
  /// The icon name.
  var icon: String
  /// The color of the icon.
  var iconColor: Color
  /// The label text.
  var label: String
  /// The shiny gradient applied to the button.
  var shiny: Gradient?
  /// The action the button will perform.
  var action: () -> ()
  
  @State private var pressed = false
  @Environment(\.useTheme) private var theme
  
  var body: some View {
    let isNotCircled = !icon.contains("circle")
    Button(action: action) {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: icon)
          .symbolRenderingMode(.palette)
          .foregroundStyle(.white, iconColor)
          .fontSize(isNotCircled ? 20 : 32)
          .padding(isNotCircled ? 5 : 0)
        Text(label)
          .fontSize(17, .semibold)
      }
      .padding(.all, 10)
      .frame(maxWidth: .infinity, alignment: .leading)
      .foregroundColor(.primary)
      .themedListRowLikeBG(pressed: pressed, shiny: shiny)
      .mask(RoundedRectangle(cornerRadius: 10).foregroundColor(.black))
      .contentShape(RoundedRectangle(cornerRadius: 13))
      //    .onChange(of: reset) { _ in active = false }
    }
    .buttonStyle(ButtonPressingProviderStyle(pressed: $pressed))
  }
}

