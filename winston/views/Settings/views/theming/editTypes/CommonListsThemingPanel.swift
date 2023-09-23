//
//  CommonListsThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI

struct CommonListsThemingPanel: View {
  @Binding var theme: WinstonTheme
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        
        FakeSection("Background", footer: "The screen's background, not the list rows.") {
          ThemeBGPicker(bg: $theme.lists.bg, defaultVal: defaultTheme.lists.bg)
        }
        
        FakeSection("Foreground color", footer: "The list rows background.") {
          ThemeForegroundEdit(theme: $theme.lists.foreground, defaultVal: defaultTheme.lists.foreground)
        }

        FakeSection("Divider") {
          SchemesColorPicker(theme: $theme.lists.dividersColors, defaultVal: defaultTheme.lists.dividersColors)
        }
      }
      .padding(.vertical, 32)
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("General")
    .navigationBarTitleDisplayMode(.inline)
  }
}

