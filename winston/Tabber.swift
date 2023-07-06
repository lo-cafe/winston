//
//  Tabber.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

enum TabIdentifier {
  case posts, inbox, me, search, settings
}

struct Tabber: View {
  @State var activeTab = TabIdentifier.posts
  @StateObject var contentLightBox = ContentLightBox()
  @Namespace var generalAnimations
  var body: some View {
    TabView(selection: $activeTab) {
      
      Subreddits()
        .tabItem {
          VStack {
            Image(systemName: "doc.text.image")
            Text("Posts")
          }
        }
        .tag(TabIdentifier.posts)
      
      Inbox()
        .tabItem {
          VStack {
            Image(systemName: "message.fill")
            Text("Inbox")
          }
        }
        .tag(TabIdentifier.inbox)
      
      Me()
        .tabItem {
          VStack {
            Image(systemName: "person.fill")
            Text("Me")
          }
        }
        .tag(TabIdentifier.me)
      
      Search()
        .tabItem {
          VStack {
            Image(systemName: "magnifyingglass")
            Text("Search")
          }
        }
        .tag(TabIdentifier.search)
      
      Settings()
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
            Text("Settings")
          }
        }
        .tag(TabIdentifier.settings)
      
    }
    .overlay(
      contentLightBox.post == nil
      ? nil
      : LightBox()
    )
    .environmentObject(NamespaceWrapper(generalAnimations))
    .environmentObject(contentLightBox)
  }
}

//struct Tabber_Previews: PreviewProvider {
//  static var previews: some View {
//    Tabber()
//  }
//}

class NamespaceWrapper: ObservableObject {
  var namespace: Namespace.ID
  
  init(_ namespace: Namespace.ID) {
    self.namespace = namespace
  }
}
