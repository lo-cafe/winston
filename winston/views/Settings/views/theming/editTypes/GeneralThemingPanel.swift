//
//  GeneralThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI

struct GeneralThemingPanel: View {
  @Binding var theme: WinstonTheme
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        
        FakeSection("General") {
          LabeledMultiline("Accent color") {
            SchemesColorPicker(theme: $theme.accentColor, defaultVal: defaultTheme.accentColor)
          }
        }
        
        FakeSection("Navigation bar", footer: "The app's top bars.") {
          ThemeForegroundEdit(theme: $theme.navPanelBG, defaultVal: defaultTheme.navPanelBG)
        }
        
        FakeSection("Tab bar", footer: "The app's bottom bar.") {
          ThemeForegroundEdit(theme: $theme.tabBarBG, defaultVal: defaultTheme.tabBarBG)
        }
        
        FakeSection("Floating panels", footer: "Like the new post button and the floating actions above post pages.") {
          ThemeForegroundEdit(theme: $theme.floatingPanelsBG, defaultVal: defaultTheme.floatingPanelsBG)
        }
        
        FakeSection("Modal panels", footer: "Like new post and new comment modals.") {
          ThemeForegroundEdit(theme: $theme.floatingPanelsBG, defaultVal: defaultTheme.floatingPanelsBG)
        }
      }
      .padding(.vertical, 32)
    }
    .scrollContentBackground(.hidden)
    .themedListBG(theme.lists.bg)
    .navigationTitle("General")
    .navigationBarTitleDisplayMode(.inline)
  }
}
