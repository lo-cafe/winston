//
//  GeneralThemingPanel.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import SwiftUI
import Defaults

struct GeneralThemingPanel: View {
  @Binding var theme: WinstonTheme
  @Default(.selectedThemeID) private var selectedThemeID
  @State private var restartAlert = false
  @State private var firstWarning = false
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 32) {
        
        FakeSection("General") {
          LabeledMultiline("Accent color") {
            SchemesColorPicker(theme: $theme.general.accentColor, defaultVal: defaultTheme.general.accentColor)
          }
        }
        
        FakeSection("Navigation bar", footer: "The app's top bars.") {
          ThemeForegroundEdit(theme: $theme.general.navPanelBG, defaultVal: defaultTheme.general.navPanelBG)
        }
        
        FakeSection("Tab bar", footer: "The app's bottom bar.") {
          ThemeForegroundEdit(theme: $theme.general.tabBarBG, defaultVal: defaultTheme.general.tabBarBG)
        }
        
        FakeSection("Floating panels", footer: "Like the new post button and the floating actions above post pages.") {
          ThemeForegroundEdit(theme: $theme.general.floatingPanelsBG, defaultVal: defaultTheme.general.floatingPanelsBG)
        }
        
        FakeSection("Modal panels", footer: "Like new post and new comment modals.") {
          ThemeForegroundEdit(theme: $theme.general.floatingPanelsBG, defaultVal: defaultTheme.general.floatingPanelsBG)
        }
      }
      .padding(.vertical, 32)
    }
    .onChange(of: theme, debounceTime: .milliseconds(500), perform: { newValue in
      if selectedThemeID == theme.id && !firstWarning {
        restartAlert = true
        firstWarning = true
      }
    })
    .scrollContentBackground(.hidden)
    .themedListBG(theme.lists.bg)
    .navigationTitle("General")
    .navigationBarTitleDisplayMode(.inline)
    .alert("Restart required", isPresented: $restartAlert) {
      Button("Gotcha!", role: .cancel) {
        restartAlert = false
      }
    } message: {
      Text("Settings in this panel requires a restart to take effect. You don't need to do it now though.")
    }
  }
}
