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
  
  @Default(.themesPresets) private var themesPresets
  @Default(.selectedThemeID) private var selectedThemeID

  var selectedTheme: WinstonTheme { themesPresets.first { $0.id == selectedThemeID } ?? defaultTheme }
  
  var body: some Scene {
    WindowGroup {
      AppContent(selectedTheme: selectedTheme)
        .onAppear { themesPresets = themesPresets.filter { $0.id != "default" } }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(\.useTheme, selectedTheme)
    }
  }
}

struct AppContent: View {
  @ObservedObject private var redditAPI = RedditAPI.shared
  var selectedTheme: WinstonTheme
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    Tabber(theme: selectedTheme, cs: cs)
    //        .alertToastRoot()
    //        .tint(selectedTheme.general.accentColor.cs(cs).color())
  }
}

private struct CurrentThemeKey: EnvironmentKey {
  static let defaultValue = defaultTheme
}

private struct ContentWidthKey: EnvironmentKey {
  static let defaultValue = UIScreen.screenWidth
}

extension EnvironmentValues {
  var contentWidth: Double {
    get { self[ContentWidthKey.self] }
    set { self[ContentWidthKey.self] = newValue }
  }
  var useTheme: WinstonTheme {
    get { self[CurrentThemeKey.self] }
    set { self[CurrentThemeKey.self] = newValue }
  }
}
