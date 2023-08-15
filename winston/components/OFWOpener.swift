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

struct OFWOpener: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var redditAPI: RedditAPI
  @ObservedObject private var OFW = OpenFromWeb.shared
  
  var body: some View {
    EmptyView()
      .onChange(of: OFW.data) { link in
        if let link = link {
          switch link {
          case .post(let id, let subreddit):
            router.path.append(PostViewPayload(post: Post(id: id, api: redditAPI), sub: Subreddit(id: subreddit, api: redditAPI)))
          case .subreddit(let name):
            router.path.append(SubredditPostsContainerPayload(sub: Subreddit(id: name, api: redditAPI)))
          case .user(let username):
            router.path.append(User(id: username, api: redditAPI))
          default:
            break
          }
        }
      }
  }
}
