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
  @StateObject private var redditAPI = RedditAPI()
  @Default(.themesPresets) private var themesPresets
  @Default(.selectedThemeID) private var selectedThemeID
  @Environment(\.colorScheme) private var cs
  @Environment(\.scenePhase) var scenePhase
  
  var biometrics = Biometrics()
  @State private var isAuthenticating = false
  @State private var isLockScreenVisible = false

  var selectedTheme: WinstonTheme { themesPresets.first { $0.id == selectedThemeID } ?? defaultTheme }
  var body: some View {
      ZStack {
          Tabber(theme: selectedTheme, cs: cs)
              .environment(\.useTheme, selectedTheme)
              .environmentObject(redditAPI)
          
          if isLockScreenVisible {
              LockScreenView().zIndex(1).edgesIgnoringSafeArea(.all)
          }

      }.onChange(of: scenePhase) { newPhase in
          let useAuth = UserDefaults.standard.bool(forKey: "useAuth")
          
          print("New phase: \(newPhase), FaceID: \(useAuth), LS: \(isLockScreenVisible), IA: \(isAuthenticating)")
          
          if (useAuth && !isAuthenticating) {
              if (newPhase == .active && isLockScreenVisible){
                  // Not authing, active and LS visible = Need to auth
                  isAuthenticating = true
                  biometrics.authenticateUser { success in
                      isLockScreenVisible = !success
                  }
                  isAuthenticating = false
              }
              else if (newPhase != .active) {
                  isLockScreenVisible = true
              }
          }
      }
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
