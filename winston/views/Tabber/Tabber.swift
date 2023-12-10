//
//  Tabber.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import SpriteKit


class TempGlobalState: ObservableObject {
  static var shared = TempGlobalState()
  @Published var editingCredential: RedditCredential? = nil
  @Published var globalLoader = GlobalLoader()
  @Published var tabBarHeight: Double? = nil
  @Published var credModalOpen = false
}

class GlobalNavPathWrapper: ObservableObject {
  @Published var path = NavigationPath()
}

struct Tabber: View, Equatable {
  static func == (lhs: Tabber, rhs: Tabber) -> Bool { true }
  
  @ObservedObject private var tempGlobalState = TempGlobalState.shared
  @ObservedObject private var redditCredentialsManager = RedditCredentialsManager.shared
  
  @State private var importedThemeAlert = false
  
  @ObservedObject private var nav = Nav.shared
  
  @Environment(\.useTheme) private var currentTheme
  @Environment(\.colorScheme) private var colorScheme
  @Default(.showUsernameInTabBar) private var showUsernameInTabBar
  
  @State var sharedTheme: ThemeData? = nil
  
  func meTabTap() {
    if nav.activeTab == .me {
      nav[.me].resetNavPath()
    } else {
      nav.activeTab = .me
    }
  }
  
  init(theme: WinstonTheme, cs: ColorScheme) {
    // MANDRAKE
    // _activeTab = State(initialValue: activeTab) // Initialize activeTab
    Tabber.updateTabAndNavBar(tabTheme: theme.general.tabBarBG, navTheme: theme.general.navPanelBG, cs)
  }
  
  static func updateTabAndNavBar(tabTheme: ThemeForegroundBG, navTheme: ThemeForegroundBG, _ cs: ColorScheme) {
    let toolbarAppearence = UINavigationBarAppearance()
    if !navTheme.blurry {
      toolbarAppearence.configureWithOpaqueBackground()
    }
    toolbarAppearence.backgroundColor = UIColor(navTheme.color.cs(cs).color())
    UINavigationBar.appearance().standardAppearance = toolbarAppearence
    let transparentAppearence = UITabBarAppearance()
    if !tabTheme.blurry {
      transparentAppearence.configureWithOpaqueBackground()
    }
    transparentAppearence.backgroundColor = UIColor(tabTheme.color.cs(cs).color())
    UITabBar.appearance().standardAppearance = transparentAppearence
  }
  
  var body: some View {
    let tabBarHeight = tempGlobalState.tabBarHeight
    let tabHeight = (tabBarHeight ?? 0) - getSafeArea().bottom
    TabView(selection: $nav.activeTab.onUpdate { newTab in if nav.activeTab == newTab { nav.resetStack() } }) {
      
      WithCredentialOnly(credential: redditCredentialsManager.selectedCredential) {
        SubredditsStack(router: nav[.posts])
      }
      .measureTabBar($tempGlobalState.tabBarHeight)
      .tag(Nav.TabIdentifier.posts)
      .tabItem { Label("Posts", systemImage: "doc.text.image") }
      
      WithCredentialOnly(credential: redditCredentialsManager.selectedCredential) {
        Inbox(router: nav[.inbox])
      }
      .tag(Nav.TabIdentifier.inbox)
      .tabItem { Label("Inbox", systemImage: "bell.fill") }
      
      WithCredentialOnly(credential: redditCredentialsManager.selectedCredential) {
        Me(router: nav[.me])
      }
      .tag(Nav.TabIdentifier.me)
      .tabItem { Label(showUsernameInTabBar ? RedditAPI.shared.me?.data?.name ?? "Me" : "Me", systemImage: "person.fill") }
      
      WithCredentialOnly(credential: redditCredentialsManager.selectedCredential) {
        Search(router: nav[.search])
      }
      .tag(Nav.TabIdentifier.search)
      .tabItem { Label("Search", systemImage: "magnifyingglass") }
      
      Settings(router: nav[.settings])
        .tag(Nav.TabIdentifier.settings)
        .tabItem { Label("Settings", systemImage: "gearshape.fill") }
      
    }
    .overlay(TabBarOverlay(tabHeight: tabHeight, meTabTap: meTabTap), alignment: .bottom)
    .openFromWebListener()
    .themeFetchingListener()
    .newCredentialListener()
    .themeImportingListener()
    .globalLoaderProvider()
    .environmentObject(tempGlobalState)
    .task(priority: .background) {
      async let _ = cleanCredentialOrphanEntities()
      async let _ = autoSelectCredentialIfNil()
      async let _ = removeDefaultThemeFromThemes()
      async let _ = removeLegacySubsAndMultisCache()
      async let _ = updatePostsInBox(RedditAPI.shared)
      if RedditCredentialsManager.shared.selectedCredential != nil {
        async let _ = RedditAPI.shared.fetchMe(force: true)
      }
      if let ann = await WinstonAPI.shared.getAnnouncement() {
        Nav.present(.announcement(ann))
      }
    }
    .accentColor(currentTheme.general.accentColor.cs(colorScheme).color())
  }
}

