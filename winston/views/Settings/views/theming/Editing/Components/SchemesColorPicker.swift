//
//  SchemesColorPicker.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct SchemesColorPicker: View {
  @Binding var theme: ColorSchemes<ThemeColor>
  var defaultVal: ColorSchemes<ThemeColor>
  @Environment(\.useTheme) private var currentTheme

  var body: some View {
    HStack {
      ThemeColorPicker("Light", $theme.light)
        .overlay(
          Color.clear
            .frame(maxWidth: .infinity)
            .resetter($theme.light, defaultVal.light)
            .padding(.trailing, 44)
        )
      
      VDivider()
      
      ThemeColorPicker("Dark", $theme.dark)
        .overlay(
          Color.clear
            .frame(maxWidth: .infinity)
            .resetter($theme.dark, defaultVal.dark)
            .padding(.trailing, 44)
        )
    }
    .padding(.horizontal, 16)
  }
}
