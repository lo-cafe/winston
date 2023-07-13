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
  @EnvironmentObject var redditAPI: RedditAPI
  @State var credModalOpen = false
  @State var reset: [TabIdentifier:Bool] = [
    .inbox: true,
    .me: true,
    .posts: true,
    .search: true,
    .settings: true,
  ]
  var body: some View {
    TabView(selection: $activeTab.onUpdate { newTab in if activeTab == newTab { reset[newTab]!.toggle() } }) {
      
      Subreddits(reset: reset[.posts]!)
        .tabItem {
          VStack {
            Image(systemName: "doc.text.image")
            Text("Posts")
          }
        }
        .tag(TabIdentifier.posts)
      
      Inbox(reset: reset[.inbox]!)
        .tabItem {
          VStack {
            Image(systemName: "message.fill")
            Text("Inbox")
          }
        }
        .tag(TabIdentifier.inbox)
      
      Me(reset: reset[.me]!)
        .tabItem {
          VStack {
            Image(systemName: "person.fill")
            Text("Me")
          }
        }
        .tag(TabIdentifier.me)
      
      Search(reset: reset[.search]!)
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
    .onAppear {
      if redditAPI.loggedUser.apiAppID == nil || redditAPI.loggedUser.apiAppSecret == nil {
        withAnimation(spring) {
          credModalOpen = true
        }
      }
    }
    .onChange(of: redditAPI.loggedUser) { user in
      if user.apiAppID == nil || user.apiAppSecret == nil {
        withAnimation(spring) {
          credModalOpen = true
        }
      }
    }
    .sheet(isPresented: $credModalOpen) {
      ChangeAuthAPIKey(open: $credModalOpen)
        .interactiveDismissDisabled(true)
    }
//    .sheet(item: $credModalOpen) {
//      ChangeAuthAPIKey()
//    }
//    .overlay(
//      contentLightBox.post == nil
//      ? nil
//      : LightBox()
//    )
//    .environmentObject(TabberNamespaceWrapper(generalAnimations))
//    .environmentObject(contentLightBox)
  }
}

//struct Tabber_Previews: PreviewProvider {
//  static var previews: some View {
//    Tabber()
//  }
//}

//class TabberNamespaceWrapper: ObservableObject {
//  var namespace: Namespace.ID
//  
//  init(_ namespace: Namespace.ID) {
//    self.namespace = namespace
//  }
//}
