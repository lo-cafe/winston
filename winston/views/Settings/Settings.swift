//
//  Settings.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import WhatsNewKit
//import SceneKit

enum SettingsPages {
  case behavior, appearance, credentials, about, commentSwipe, postSwipe, accessibility, faq, general, postFontSettings, themes, filteredSubreddits, appIcon, themeStore
}

struct Settings: View {
  var reset: Bool
  @ObservedObject var router: Router
  @Environment(\.openURL) private var openURL
  @Default(.likedButNotSubbed) var likedButNotSubbed
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @State private var id = UUID().uuidString
    
  @EnvironmentObject var winstonAPI: WinstonAPI

  @State var presentingWhatsNew: Bool = false
  @State var presentingAnnouncement: Bool = false
  var body: some View {
    NavigationStack(path: $router.path) {
  
      RouterProxyInjector(routerProxy: RouterProxy(router)) { routerProxy in
        List {
          Group {
            Section {
              WSNavigationLink(SettingsPages.general, "General", icon: "gear")
              WSNavigationLink(SettingsPages.behavior, "Behavior", icon: "arrow.triangle.turn.up.right.diamond.fill")
              WSNavigationLink(SettingsPages.appearance, "Appearance", icon: "theatermask.and.paintbrush.fill")
              WSNavigationLink(SettingsPages.credentials, "Credentials", icon: "key.horizontal.fill")
            }
            
            Section {
              WSNavigationLink(SettingsPages.faq, "FAQ", icon: "exclamationmark.questionmark")
              WSNavigationLink(SettingsPages.about, "About", icon: "cup.and.saucer.fill")
              WSListButton("Whats New", icon: "star") {
                presentingWhatsNew.toggle()
              }
              .disabled(getCurrentChangelog().isEmpty)
              
              WSListButton("Announcements", icon: "newspaper") {
                presentingAnnouncement.toggle()
              }
              
              WSListButton("Donate monthly", icon: "heart.fill") {
                openURL(URL(string: "https://patreon.com/user?u=93745105")!)
              }
              
              WListButton {
                openURL(URL(string: "https://ko-fi.com/locafe")!)
              } label: {
                Label {
                  Text("Tip jar")
                } icon: {
                  Image("jar")
                    .resizable()
                    .scaledToFit()
                }
              }

              
//              Button {
//                openURL(URL(string: "https://ko-fi.com/locafe")!)
//              } label: {
//                Label {
//                  Text("Tip jar")
//                } icon: {
//                  Image("jar")
//                    .resizable()
//                    .scaledToFit()
//                }
//              }
              
            }
          }
          .themedListSection()
          
        }
        .sheet(isPresented: $presentingWhatsNew){
          if let isNew = getCurrentChangelog().first {
              WhatsNewView(whatsNew: isNew)
          }
        }
        .sheet(isPresented: $presentingAnnouncement){
          
          if let announcement = winstonAPI.announcement {
            AnnouncementSheet(showingAnnouncement: $presentingAnnouncement, announcement: announcement)
          } else {
            ProgressView()
              .onAppear{
                Task(priority: .userInitiated){
                  winstonAPI.announcement = await winstonAPI.getAnnouncement()
                }
              }
          }
        }
        .themedListBG(selectedTheme.lists.bg)
        .scrollContentBackground(.hidden)
        .navigationDestination(for: SettingsPages.self) { x in
          Group {
            switch x {
            case .general:
              GeneralPanel()
            case .behavior:
              BehaviorPanel()
            case .appearance:
              AppearancePanel()
            case .credentials:
              CredentialsPanel()
            case .about:
              AboutPanel()
            case .commentSwipe:
              CommentSwipePanel()
            case .postSwipe:
              PostSwipePanel()
            case .accessibility:
              AccessibilityPanel()
            case .postFontSettings:
              PostFontSettings()
            case .filteredSubreddits:
              FilteredSubredditsSettings()
            case .faq:
              FAQPanel()
            case .themes:
              ThemesPanel()
            case .themeStore:
              ThemeStore()
            case .appIcon:
              AppIconSetting()
            }
          }
          .environmentObject(router)
          .environmentObject(routerProxy)
        }
        .environmentObject(router)
        .environmentObject(routerProxy)
        .navigationTitle("Settings")
        .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
      }
    }
    
  }
}

//struct Settings_Previews: PreviewProvider {
//  static var previews: some View {
//    Settings()
//  }
//}
