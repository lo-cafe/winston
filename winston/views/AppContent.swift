//
//  AppContent.swift
//  winston
//
//  Created by Igor Marcossi on 31/12/23.
//

import SwiftUI
import Defaults

struct AppContent: View {
  @StateObject private var themeStore = ThemeStoreAPI()
  @Environment(\.scenePhase) var scenePhase
  
//  @Default(.ThemesDefSettings) private var themesDefSettings
  @Default(.GeneralDefSettings) private var generalDefSettings

//  var selectedTheme: WinstonTheme { themesDefSettings.themesPresets.first { $0.id == themesDefSettings.selectedThemeID } ?? defaultTheme }
  
  let biometrics = Biometrics()
  @State private var isAuthenticating = false
  @State private var tabBarHeight: Double = 0
  @State private var lockBlur: Int = 50 // Set initial startup blur
  @State private var restartAlert = false
    
  func setTabBarHeight(_ val: Double) {
    tabBarHeight = val
  }
  
  var body: some View {
    AccountSwitcherProvider {
      GlobalDestinationsProvider {
        Tabber(theme: InMemoryTheme.shared.currentTheme).equatable()
      }
    }
    .whatsNewSheet()
    .environment(\.tabBarHeight, tabBarHeight)
    .environment(\.setTabBarHeight, setTabBarHeight)
    .environmentObject(themeStore)
    .environment(\.useTheme, InMemoryTheme.shared.currentTheme)
    .onAppear { Defaults[.ThemesDefSettings].themesPresets = Defaults[.ThemesDefSettings].themesPresets.filter { $0.id != "default" } }
    .onChange(of: InMemoryTheme.shared.currentTheme, initial: false) { old, new in
      restartAlert = old.general != new.general
    }
    .alert("Restart required", isPresented: $restartAlert) {
      Button("Gotcha!", role: .cancel) {
        restartAlert = false
      }
    } message: {
      Text("This theme changes a few settings (like the visuals of tab/nav bars) that requires an app restart to take effect.")
    }
    .onChange(of: scenePhase) { _, newPhase in
      // No auth on MacOS
      var runningOnMac = false
      #if os(macOS)
        runningOnMac = true
      #endif

      let useAuth = generalDefSettings.useAuth // Get fresh value
      
      if (useAuth && !runningOnMac) {
        if (!isAuthenticating && newPhase == .active && lockBlur != 0){
          // Not authing, active and blur visible = Need to auth
          isAuthenticating = true
          biometrics.authenticateUser { success in
            if success {
              lockBlur = 0
            }
          }
        }
        else if (newPhase != .active) {
          // Auth enabled but not active = blur
          lockBlur = 50
        }
        isAuthenticating = false
      } else {
          // Auth not enabled = No blur
          lockBlur = 0
      }
      
      switch newPhase {
      case .active :
        guard let name = shortcutItemToProcess?.userInfo?["name"] as? String else {
          return
        }
        switch name {
        case savedKeyword:
          print("\(savedKeyword) is selected")
        case "search":
          print("search is selected")
          // MANDRAKE
          // activeTab = .search // Set the active tab to "Search"
        default:
          print("default " + name)
        }
      case .inactive:
        // inactive
        break
      case .background:
        addQuickActions()
      @unknown default:
        print("default")
      }
    }
    .blur(radius: CGFloat(lockBlur)) // Set lockscreen blur
  }
  
  func addQuickActions() {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var subreddits: FetchedResults<CachedSub>
    
    var searchUserInfo: [String: NSSecureCoding] {
      return ["name" : "search" as NSSecureCoding]
    }
    var savedInfo: [String: NSSecureCoding] {
      return ["name" : savedKeyword as NSSecureCoding]
    }
    var statususerInfo: [String: NSSecureCoding] {
      return ["name" : "status" as NSSecureCoding]
    }
    var contactuserInfo: [String: NSSecureCoding] {
      return ["name" : "contact" as NSSecureCoding]
    }
    
    UIApplication.shared.shortcutItems = [
      UIApplicationShortcutItem(type: "Search", localizedTitle: "Search", localizedSubtitle: "Search a Subreddit", icon: UIApplicationShortcutIcon(type: .search), userInfo: searchUserInfo),
      UIApplicationShortcutItem(type: "Saved", localizedTitle: "Saved", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .bookmark), userInfo: savedInfo),
    ]
    
  }
}
