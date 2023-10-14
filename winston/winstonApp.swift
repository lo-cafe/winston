//
//  winstonApp.swift
//  winston
//
//  Created by Igor Marcossi on 23/06/23.
//

import SwiftUI
import AlertToast
import Defaults
var shortcutItemToProcess: UIApplicationShortcutItem?
@main
struct winstonApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  let persistenceController = PersistenceController.shared
  @Environment(\.scenePhase) var phase
  @State private var activeTab: TabIdentifier = .posts

  var body: some Scene {
    WindowGroup {
      AppContent(activeTab: activeTab)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    .onChange(of: phase) { (newPhase) in
      switch newPhase {
      case .active :
        guard let name = shortcutItemToProcess?.userInfo?["name"] as? String else {
          return
        }
        switch name {
        case "saved":
          print("saved is selected")
          //quickActionSettings.quickAction = .details(name: name)
        case "search":
          print("search is selected")
            activeTab = .search // Set the active tab to "Search"
          //set active tab to search
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
  @ObservedObject private var redditAPI = RedditAPI.shared
  @StateObject private var themeStore = ThemeStoreAPI()
  @Default(.themesPresets) private var themesPresets
  @Default(.selectedThemeID) private var selectedThemeID
  @Environment(\.colorScheme) private var cs
  @Environment(\.scenePhase) var scenePhase
  @State var activeTab: TabIdentifier
  
  let biometrics = Biometrics()
  @State private var isAuthenticating = false
  @State private var lockBlur = UserDefaults.standard.bool(forKey: "useAuth") ? 50 : 0 // Set initial startup blur
  
  var selectedThemeRaw: WinstonTheme? { themesPresets.first { $0.id == selectedThemeID } }
  var body: some View {
    let selectedTheme = selectedThemeRaw ?? defaultTheme
    Tabber(theme: selectedTheme, cs: cs, activeTab: activeTab)
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
