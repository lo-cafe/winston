//
//  ThemeForegroundEdit.swift
//  winston
//
//  Created by Igor Marcossi on 15/09/23.
//

import SwiftUI

struct ThemeForegroundEdit: View {
  @Binding var theme: ThemeForegroundBG
  var defaultVal: ThemeForegroundBG
    var body: some View {
      Group {
        Toggle("Blur background", isOn: $theme.blurry)
          .padding(.horizontal, 16)
          .resetter($theme.blurry, defaultVal.blurry)

        Divider()

        LabeledMultiline("Background color") {
          SchemesColorPicker(theme: $theme.color, defaultVal: defaultVal.color)
        }
      }
    }
}
