//
//  Settings.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
//import SceneKit

enum SettingsPages {
  case behavior, appearance, account, about, commentSwipe, postSwipe, accessibility, faq, general, postFontSettings, themes
}

struct Settings: View {
  var reset: Bool
  @ObservedObject var router: Router
  @Environment(\.openURL) private var openURL
  @Default(.likedButNotSubbed) var likedButNotSubbed
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  @State private var id = UUID().uuidString
  var body: some View {
    NavigationStack(path: $router.path) {
      List {
        Group {
          Section {
            NavigationLink(value: SettingsPages.general) {
              Label("General", systemImage: "gear")
            }
            NavigationLink(value: SettingsPages.behavior) {
              Label("Behavior", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
            }
            NavigationLink(value: SettingsPages.appearance) {
              Label("Appearance", systemImage: "theatermask.and.paintbrush.fill")
            }
            NavigationLink(value: SettingsPages.account) {
              Label("Account", systemImage: "person.crop.circle")
            }
            //            NavigationLink(value: SettingsPages.accessibility) {
            //              Label("Accessibility", systemImage: "figure.roll")
            //            }
            
          }
          
          Section {
            NavigationLink(value: SettingsPages.faq){
              Label("FAQ", systemImage: "exclamationmark.questionmark")
            }
            NavigationLink(value: SettingsPages.about) {
              Label("About", systemImage: "cup.and.saucer.fill")
            }
            Button {
              sendCustomEmail()
            } label: {
              Label("Report a bug", systemImage: "ladybug.fill")
            }
            Button {
              openURL(URL(string: "https://patreon.com/user?u=93745105")!)
            } label: {
              Label("Donate monthly", systemImage: "heart.fill")
            }
            Button {
              openURL(URL(string: "https://ko-fi.com/locafe")!)
            } label: {
              HStack {
                Image("jar")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 28, height: 16)
                  .padding(.trailing, 9)
                Text("Tip jar")
              }
            }
            
          }
        }
        .listRowSeparatorTint(selectedTheme.lists.dividersColors.cs(cs).color())
//        .listRowBackground(Rectangle().fill(selectedTheme.lists.foreground.blurry ? AnyShapeStyle(.bar) : AnyShapeStyle(selectedTheme.lists.foreground.color.cs(cs).color())).overlay(!selectedTheme.lists.foreground.blurry ? nil : Rectangle().fill(selectedTheme.lists.foreground.color.cs(cs).color())))
        
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
          case .faq:
            FAQPanel()
          case .themes:
            ThemesPanel()
          }
        }
        .environmentObject(router)
      }
      .navigationTitle("Settings")
      .environmentObject(router)
      .onChange(of: reset) { _ in router.path.removeLast(router.path.count) }
    }
  }
}

//struct Settings_Previews: PreviewProvider {
//  static var previews: some View {
//    Settings()
//  }
//}
