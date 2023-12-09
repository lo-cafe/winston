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

          }
        }
        .themedListSection()
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
        .navigationTitle("Settings")
      }
    }
    
  }
}

//struct Settings_Previews: PreviewProvider {
//  static var previews: some View {
//    Settings()
//  }
//}
