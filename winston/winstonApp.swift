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
  @StateObject private var themeStore = ThemeStoreAPI()
  @Default(.themesPresets) private var themesPresets
  @Default(.selectedThemeID) private var selectedThemeID
  @Environment(\.colorScheme) private var cs
  @Environment(\.scenePhase) var scenePhase
  
  let biometrics = Biometrics()
  @State private var isAuthenticating = false
  @State private var lockBlur = UserDefaults.standard.bool(forKey: "useAuth") ? 50 : 0 // Set initial startup blur

  var selectedThemeRaw: WinstonTheme? { themesPresets.first { $0.id == selectedThemeID } }
  var body: some View {
    let selectedTheme = selectedThemeRaw ?? defaultTheme
    Tabber(theme: selectedTheme, cs: cs)
      .onAppear {
        themesPresets = themesPresets.filter { $0.id != "default" }
        if selectedThemeRaw.isNil { selectedThemeID = "default" }
      }
      .environment(\.useTheme, selectedTheme)
      .environmentObject(themeStore)
    //        .alertToastRoot()
    //        .tint(selectedTheme.general.accentColor.cs(cs).color())
      .onChange(of: scenePhase) { newPhase in
        let useAuth = UserDefaults.standard.bool(forKey: "useAuth") // Get fresh value
          
        if (useAuth && !isAuthenticating) {
          if (newPhase == .active && lockBlur == 50){
            // Not authing, active and blur visible = Need to auth
            isAuthenticating = true
            biometrics.authenticateUser { success in
              if success {
                lockBlur = 0
              }
            }
            isAuthenticating = false
          }
          else if (newPhase != .active) {
            lockBlur = 50
          }
        }
      }.blur(radius: CGFloat(lockBlur)) // Set lockscreen blur
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
