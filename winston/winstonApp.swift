//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI
import AlertToast
import Defaults

@main
struct winstonApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      AppContent()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}

struct AppContent: View {
  @ObservedObject private var redditAPI = RedditAPI.shared
  @Default(.themesPresets) private var themesPresets
  @Default(.selectedThemeID) private var selectedThemeID
  @Environment(\.colorScheme) private var cs
  
  var selectedThemeRaw: WinstonTheme? { themesPresets.first { $0.id == selectedThemeID } }
  var body: some View {
    let selectedTheme = selectedThemeRaw ?? defaultTheme
    Tabber(theme: selectedTheme, cs: cs)
      .onAppear {
        themesPresets = themesPresets.filter { $0.id != "default" }
        if selectedThemeRaw.isNil { selectedThemeID = "default" }
      }
      .environment(\.useTheme, selectedTheme)
    //        .alertToastRoot()
    //        .tint(selectedTheme.general.accentColor.cs(cs).color())
  }
}

private struct CurrentThemeKey: EnvironmentKey {
  static let defaultValue = defaultTheme
}

extension EnvironmentValues {
  var useTheme: WinstonTheme {
    get { self[CurrentThemeKey.self] }
    set { self[CurrentThemeKey.self] = newValue }
  }
}
