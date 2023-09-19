//
//  PostPageTheming.swift
//  winston
//
//  Created by Igor Marcossi on 15/09/23.
//

import SwiftUI

struct PostPageTheming: View {
  @Binding var theme: PostTheme
  var body: some View {
    FakeSection("Page") {
      LabeledSlider(label: "Elements spacing", value: $theme.spacing, range: 0...64)
        .resetter($theme.spacing, defaultTheme.posts.spacing)
      
      Divider()
      
      ThemeBGPicker(bg: $theme.bg, defaultVal: defaultTheme.posts.bg)
      
      Divider()
      
      LabeledSlider(label: "Horizontal padding", value: $theme.padding.horizontal, range: 0...64)
        .resetter($theme.padding.horizontal, defaultTheme.posts.padding.horizontal)
      
      Divider()
      
      LabeledSlider(label: "Vertical padding", value: $theme.padding.vertical, range: 0...64)
        .resetter($theme.padding.vertical, defaultTheme.posts.padding.vertical)
    }
  }
}
