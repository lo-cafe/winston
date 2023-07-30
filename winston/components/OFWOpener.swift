//
//  OFWOpener.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import SwiftUI

class OpenFromWeb: ObservableObject {
  static var shared = OpenFromWeb()
  @Published var data: RedditURLType?
}

private struct OFWPostData: Equatable, Hashable, Identifiable {
  var id: String = "a"
  var subreddit: String = ""
}
private struct OFWUserData: Equatable, Hashable, Identifiable {
  var username: String = "a"
  var id: String { self.username }
}
private struct OFWSubData: Equatable, Hashable, Identifiable {
  var name: String = "a"
  var id: String { self.name }
}

struct OFWOpener: View {
  var reset: Bool
  @State private var OFWPostActive = false
  @State private var OFWUserActive = false
  @State private var OFWSubActive = false
  @State private var OFWPost = OFWPostData()
  @State private var OFWUser = OFWUserData()
  @State private var OFWSub = OFWSubData()
  
  @EnvironmentObject var redditAPI: RedditAPI
  @ObservedObject var OFW = OpenFromWeb.shared
  
  func resetOFW() {
    OFW.data = nil
  }
  
  var body: some View {
    EmptyView()
      .background(
        NavigationLink(destination: PostViewContainer(post: Post(id: OFWPost.id, api: redditAPI), sub: Subreddit(id: OFWPost.subreddit, api: redditAPI)), isActive: $OFWPostActive, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false).id(OFWPost.id)
      )
      .background(
        NavigationLink(destination: UserView(user: User(id: OFWUser.username, api: redditAPI)), isActive: $OFWUserActive, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false).id(OFWUser.id)
      )
      .background(
        NavigationLink(destination: SubredditPostsContainer(sub: Subreddit(id: OFWSub.name, api: redditAPI)), isActive: $OFWSubActive, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false).id(OFWSub.id)
      )
      .onChange(of: reset) { _ in
        OFWPostActive = false
        OFWUserActive = false
        OFWSubActive = false
      }
      .onChange(of: OFWPostActive) { if !$0 { doThisAfter(0.3) { OFWPost = OFWPostData(); resetOFW() } } }
      .onChange(of: OFWUserActive) { if !$0 { doThisAfter(0.3) { OFWUser = OFWUserData(); resetOFW() } } }
      .onChange(of: OFWSubActive) { if !$0 { doThisAfter(0.3) { OFWSub = OFWSubData(); resetOFW() } } }
      .onChange(of: OFW.data) { link in
        if let link = link {
          switch link {
          case .post(let id, let subreddit):
            OFWPost = OFWPostData(id: id, subreddit: subreddit)
            doThisAfter(0) { OFWPostActive = true }
          case .subreddit(let name):
            OFWSub = OFWSubData(name: name)
            doThisAfter(0) { OFWSubActive = true }
          case .user(let username):
            OFWUser = OFWUserData(username: username)
            doThisAfter(0) { OFWUserActive = true }
          default:
            break
          }
        }
      }
  }
}
