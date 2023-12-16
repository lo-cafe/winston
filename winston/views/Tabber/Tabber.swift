//
//  Tabber.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import SpriteKit

struct Tabber: View, Equatable {
  static func == (lhs: Tabber, rhs: Tabber) -> Bool { true }
  
  @ObservedObject private var redditCredentialsManager = RedditCredentialsManager.shared
  @ObservedObject private var nav = Nav.shared
  
  @State var tabBarHeight: Double? = nil
  
  @Environment(\.useTheme) private var currentTheme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.setTabBarHeight) private var setTabBarHeight
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
    TabView(selection: $nav.activeTab.onUpdate { newTab in if nav.activeTab == newTab { nav.resetStack() } }) {
      
      WithCredentialOnly(credential: redditCredentialsManager.selectedCredential) {
        SubredditsStack(router: nav[.posts])
      }
      .measureTabBar(setTabBarHeight)
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
    .overlay(TabBarOverlay(meTabTap: meTabTap), alignment: .bottom)
    .openFromWebListener()
    .themeFetchingListener() // From WinstonAPI
    .newCredentialListener()
    .themeImportingListener() // From local file
    .globalLoaderProvider()
    .refetchMeListener()
    .task(priority: .background) {
      cleanCredentialOrphanEntities()
      autoSelectCredentialIfNil()
      removeDefaultThemeFromThemes()
      removeLegacySubsAndMultisCache()
      if RedditCredentialsManager.shared.selectedCredential != nil {
        RedditCredentialsManager.shared.updateMe()
        Task(priority: .background) { await updatePostsInBox(RedditAPI.shared) }
      }
//      if let ann = await WinstonAPI.shared.getAnnouncement() {
//        Nav.present(.announcement(ann))
//      }
    }
    .accentColor(currentTheme.general.accentColor.cs(colorScheme).color())
  }
}

