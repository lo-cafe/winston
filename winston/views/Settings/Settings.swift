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

struct Settings: View {
  @ObservedObject var router: Router
  @Environment(\.openURL) private var openURL
  @Default(.likedButNotSubbed) var likedButNotSubbed
  @Environment(\.useTheme) private var selectedTheme
  @State private var id = UUID().uuidString
  
  @ObservedObject var winstonAPI = WinstonAPI.shared
  
  @State var presentingWhatsNew: Bool = false
  @State var presentingAnnouncement: Bool = false
  var body: some View {
    NavigationStack(path: $router.fullPath) {
      
      List {
        Group {
          Section {
            WSNavigationLink(.setting(.general), "General", icon: "gear")
            WSNavigationLink(.setting(.behavior), "Behavior", icon: "arrow.triangle.turn.up.right.diamond.fill")
            WSNavigationLink(.setting(.appearance), "Appearance", icon: "theatermask.and.paintbrush.fill")
            WSNavigationLink(.setting(.credentials), "Credentials", icon: "key.horizontal.fill")
          }
          
          Section {
            WSNavigationLink(.setting(.faq), "FAQ", icon: "exclamationmark.questionmark")
            WSNavigationLink(.setting(.about), "About", icon: "cup.and.saucer.fill")
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
      }
      .themedListSection()
      .sheet(isPresented: $presentingWhatsNew){
        if let isNew = getCurrentChangelog().first {
          WhatsNewView(whatsNew: isNew)
        }
      }
      .themedListBG(selectedTheme.lists.bg)
      .scrollContentBackground(.hidden)
      .navigationTitle("Settings")
      .injectInTabDestinations()
    }
  }
}

//struct Settings_Previews: PreviewProvider {
//  static var previews: some View {
//    Settings()
//  }
//}
