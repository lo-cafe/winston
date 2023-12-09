//
//  ThemeColorPicker.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct ThemeColorPicker: View {
  var label: String
  @Binding var theme: ThemeColor
  
  init(_ label: String, _ theme: Binding<ThemeColor>) {
    self.label = label
    self._theme = theme
  }
    var body: some View {
      ColorPicker(label, selection: Binding(get: {
        theme.color()
      }, set: { val, _ in
        var newTheme = theme
        newTheme.hex = val.hex
        newTheme.alpha = val.alpha
        theme = newTheme
      }))
    }
}

