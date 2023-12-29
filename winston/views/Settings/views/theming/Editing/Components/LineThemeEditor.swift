//
//  LineThemeEditor.swift
//  winston
//
//  Created by Igor Marcossi on 15/09/23.
//

import SwiftUI

struct LineThemeEditor: View {
  @Binding var theme: LineTheme
  var defaultVal: LineTheme
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      SchemesColorPicker(theme: $theme.color, defaultVal: defaultVal.color)
      if let defaultStyle = defaultVal.style {
        Divider()
        HStack {
          Text("Style")
          Spacer()
          TagsOptions($theme.style, options: [
            CarouselTagElement(label: "Fancy", value: LineTypeTheme.fancy),
            CarouselTagElement(label: "Line", value: LineTypeTheme.line),
            CarouselTagElement(label: "None", value: LineTypeTheme.no)
          ])
        }
        .onChange(of: theme.style) { val in
          if val == .fancy { theme.color = defaultFancyDivider.color }
        }
        .padding(.horizontal, 16)
        .resetter($theme.style, defaultStyle)
        if theme.style == .fancy {
          Divider()
          LabeledSlider(label: "Thickness", value: $theme.thickness, range: 1...24)
            .resetter($theme.thickness, defaultVal.thickness)
        }
      }
    }
  }
}
