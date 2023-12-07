//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI
import AlertToast
import Defaults
import WhatsNewKit

var shortcutItemToProcess: UIApplicationShortcutItem?
@main
struct winstonApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  let persistenceController = PersistenceController.shared
  
  @Default(.themesPresets) private var themesPresets
  @Default(.selectedThemeID) private var selectedThemeID
  @Default(.redditCredentialSelectedID) private var redditCredentialSelectedID
  
  var selectedTheme: WinstonTheme { themesPresets.first { $0.id == selectedThemeID } ?? defaultTheme }
  
  var body: some Scene {
    WindowGroup {
      AppContent(selectedTheme: selectedTheme)
        .onAppear { themesPresets = themesPresets.filter { $0.id != "default" } }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environment(
          \.whatsNew,
           WhatsNewEnvironment(currentVersion: .current(), whatsNewCollection: getCurrentChangelog())
        )
        .environment(\.useTheme, selectedTheme)
        .onAppear {
          cleanEntitiesWithNilCredentials()
          if redditCredentialSelectedID == nil {
            let validCreds = RedditCredentialsManager.shared.validCredentials
            if validCreds.count > 0 { redditCredentialSelectedID = validCreds[0].id }
          }
        }
        .onChange(of: redditCredentialSelectedID) { val in
          Task(priority: .background) { await RedditAPI.shared.fetchMe(force: true) }
          Task(priority: .background) { await RedditAPI.shared.fetchSubs() }
          Task(priority: .background) { await RedditAPI.shared.fetchMyMultis() }
        }
    }
  }
  
  func addQuickActions() {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], animation: .default) var subreddits: FetchedResults<CachedSub>
    
    var searchUserInfo: [String: NSSecureCoding] {
      return ["name" : "search" as NSSecureCoding]
    }
    var savedInfo: [String: NSSecureCoding] {
      return ["name" : "saved" as NSSecureCoding]
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

struct AppContent: View {
  @ObservedObject private var winstonAPI = WinstonAPI()
  var selectedTheme: WinstonTheme
  @StateObject private var themeStore = ThemeStoreAPI()
  @Environment(\.colorScheme) private var cs
  @Environment(\.scenePhase) var scenePhase
  
  let biometrics = Biometrics()
  @State private var isAuthenticating = false
  @State private var lockBlur = UserDefaults.standard.bool(forKey: "useAuth") ? 50 : 0 // Set initial startup blur
  
  var body: some View {
    AccountSwitcherProvider {
      Tabber(theme: selectedTheme, cs: cs).equatable()
    }
    .whatsNewSheet()
    .environmentObject(winstonAPI)
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
        }
        else if (newPhase != .active) {
          lockBlur = 50
        }
        isAuthenticating = false
      }
      
      switch newPhase {
      case .active :
        guard let name = shortcutItemToProcess?.userInfo?["name"] as? String else {
          return
        }
        switch name {
        case "saved":
          print("saved is selected")
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
      return ["name" : "saved" as NSSecureCoding]
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

private struct ChangeAppTabWithPathFuncKey: EnvironmentKey {
  static let defaultValue: (TabIdentifier, NavigationPath) -> () = { _, _ in }
}

private struct ChangeAppTabFuncKey: EnvironmentKey {
  static let defaultValue: (TabIdentifier) -> () = { _ in }
}

private struct CurrentThemeKey: EnvironmentKey {
  static let defaultValue = defaultTheme
}

private struct ContentWidthKey: EnvironmentKey {
  static let defaultValue = UIScreen.screenWidth
}

extension EnvironmentValues {
  var changeAppTabWithPath: (TabIdentifier, NavigationPath) -> () {
    get { self[ChangeAppTabWithPathFuncKey.self] }
    set { self[ChangeAppTabWithPathFuncKey.self] = newValue }
  }
  var changeAppTab: (TabIdentifier) -> () {
    get { self[ChangeAppTabFuncKey.self] }
    set { self[ChangeAppTabFuncKey.self] = newValue }
  }
  var contentWidth: Double {
    get { self[ContentWidthKey.self] }
    set { self[ContentWidthKey.self] = newValue }
  }
  var useTheme: WinstonTheme {
    get { self[CurrentThemeKey.self] }
    set { self[CurrentThemeKey.self] = newValue }
  }
}

