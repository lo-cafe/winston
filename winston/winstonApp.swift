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
  
  var biometrics = Biometrics()
  var useFaceID = UserDefaults.standard.bool(forKey: "useFaceID")
  var selectedTheme: WinstonTheme { themesPresets.first { $0.id == selectedThemeID } ?? defaultTheme }
  var body: some View {
    Tabber(theme: selectedTheme, cs: cs)
      .environment(\.useTheme, selectedTheme)
      .environmentObject(redditAPI)
      .onAppear {
        // Biometrics
        if useFaceID {
          biometrics.showLockedScreen(backgroundColor: .systemYellow, logo: nil, width: 0, toView: UIApplication.shared.windows.first!)
          biometrics.authenticateUser()
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
