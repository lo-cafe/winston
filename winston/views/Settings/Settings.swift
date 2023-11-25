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
  case behavior, appearance, account, about, commentSwipe, postSwipe, accessibility, faq, general, postFontSettings, themes, filteredSubreddits, appIcon, themeStore
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
              WNavigationLink(value: SettingsPages.general) {
                Label("General", systemImage: "gear")
              }
              WNavigationLink(value: SettingsPages.behavior) {
                Label("Behavior", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
              }
              WNavigationLink(value: SettingsPages.appearance) {
                Label("Appearance", systemImage: "theatermask.and.paintbrush.fill")
              }
              WNavigationLink(value: SettingsPages.account) {
                Label("Account", systemImage: "person.crop.circle")
              }
            }
            
            Section {
              WNavigationLink(value: SettingsPages.faq){
                Label("FAQ", systemImage: "exclamationmark.questionmark")
              }
              WNavigationLink(value: SettingsPages.about) {
                Label("About", systemImage: "cup.and.saucer.fill")
              }
              
              WListButton {
                presentingWhatsNew.toggle()
              } label: {
                Label("Whats New", systemImage: "star")
              }
              .disabled(getCurrentChangelog().isEmpty)
              
              WListButton {
               
                presentingAnnouncement.toggle()
              } label: {
                Label("Announcements", systemImage: "newspaper")
              }
              
              WSListButton("Donate monthly", icon: "heart.fill") {
                openURL(URL(string: "https://patreon.com/user?u=93745105")!)
              }
              .accentColor(.red)
              
              WListButton {
                openURL(URL(string: "https://ko-fi.com/locafe")!)
              } label: {
                HStack {
                  Image("jar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 32)
                    .padding(.trailing, 9)
                    .foregroundStyle(Color.accentColor)
                  Text("Tip jar")
                }
              }
              
            }
          }
          .themedListDividers()
          
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
            case .account:
              AccountPanel()
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
