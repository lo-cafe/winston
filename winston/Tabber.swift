//
//  Tabber.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults

class Oops: ObservableObject {
  static var shared = Oops()
  @Published var asking = false
  @Published var error: String?
  
  func sendError(_ error: Any) {
    DispatchQueue.main.async {
      Oops.shared.asking = true
      Oops.shared.error = String(reflecting: error)
    }
  }
}

class TempGlobalState: ObservableObject {
  @Published var loadingText: String?
}

enum TabIdentifier {
  case posts, inbox, me, search, settings
}

struct Tabber: View {
  @ObservedObject var errorAlert = Oops.shared
  @State var activeTab = TabIdentifier.posts
  @StateObject var tempGlobalState = TempGlobalState()
  @EnvironmentObject var redditAPI: RedditAPI
  @State var credModalOpen = false
  @State var reset: [TabIdentifier:Bool] = [
    .inbox: true,
    .me: true,
    .posts: true,
    .search: true,
    .settings: true,
  ]
  @Default(.postsInBox) var postsInBox
  @Default(.showUsernameInTabBar) var showUsernameInTabBar
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
              if let me = redditAPI.me {
                  if let data = me.data {
                      Text(showUsernameInTabBar ? data.name : "Me")
                  }
              } else {
                  Text("Me")
              }
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
      
      Settings(reset: reset[.settings]!)
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
            Text("Settings")
          }
        }
        .tag(TabIdentifier.settings)
      
    }
    .overlay(
      HStack(spacing: 8) {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .teal))

        Text(tempGlobalState.loadingText ?? "Commenting...")
          .foregroundColor(.teal)
          .fontSize(15, .medium)
          
      }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .floating()
        .offset(y: tempGlobalState.loadingText.isNil ? 75 : -62)
      , alignment: .bottom
    )
    .environmentObject(tempGlobalState)
    .alert("OMG! Winston found a squirky bug!", isPresented: $errorAlert.asking) {
      Button("Gratefully accept the weird gift") {
        if let error = errorAlert.error {
          sendEmail(error)
        }
        errorAlert.error = nil
        errorAlert.asking = false
      }
      Button("Ignore the cat", role: .cancel) {
        errorAlert.error = nil
        errorAlert.asking = false
      }
    } message: {
      Text("Something went wrong, but winston's is a fast cat, got the bug in his fangs and brought it to you. What do you wanna do?")
    }
    .onAppear {
      Task { await updatePostsInBox(redditAPI) }
      if redditAPI.loggedUser.apiAppID == nil || redditAPI.loggedUser.apiAppSecret == nil {
        withAnimation(spring) {
          credModalOpen = true
        }
      } else if redditAPI.loggedUser.accessToken != nil && redditAPI.loggedUser.refreshToken != nil {
        Task {
          await redditAPI.fetchMe(force: true)
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
    .onOpenURL { url in
      let parsed = parseRedditURL(url.absoluteString)
      withAnimation {
        switch parsed {
        case .post(_, _):
          OpenFromWeb.shared.data = parsed
        case .subreddit(_):
          OpenFromWeb.shared.data = parsed
        case .user(_):
          OpenFromWeb.shared.data = parsed
        default:
          break
        }
      }
    }
//    .sheet(isPresented: $credModalOpen) {
//      ChangeAuthAPIKey(open: $credModalOpen)
//        .interactiveDismissDisabled(true)
//    }
    .sheet(isPresented: $credModalOpen) {
      Onboarding(open: $credModalOpen)
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
