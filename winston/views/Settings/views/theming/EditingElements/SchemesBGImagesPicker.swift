//
//  SchemesBGImagesPicker.swift
//  winston
//
//  Created by Igor Marcossi on 14/09/23.
//

import SwiftUI

struct SchemesBGImagesPicker: View {
  @Binding var theme: ColorSchemes<String>
  var defaultVal: ColorSchemes<String>
  @Environment(\.useTheme) private var currentTheme
  @Environment(\.colorScheme) private var cs
    var body: some View {
      HStack {
        ImageThemePicker(label: "Light", image: $theme.light)
          .resetter($theme.light, defaultVal.light)
        
        VDivider()
        
        ImageThemePicker(label: "Dark", image: $theme.dark)
          .resetter($theme.dark, defaultVal.dark)
      }
      .padding(.horizontal, 16)
    }
}
