//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  var reset: Bool
  @Environment(\.openURL) private var openURL
  @EnvironmentObject private var redditAPI: RedditAPI
  @State private var loading = true
  @StateObject private var router = Router()
  var body: some View {
    NavigationStack(path: $router.path) {
      Group {
        if let user = redditAPI.me {
          UserView(user: user)
            .navigationDestination(for: PostViewPayload.self) { postPayload in
              PostView(post: postPayload.post, subreddit: postPayload.sub, highlightID: postPayload.highlightID)
                .environmentObject(router)
            }
            .navigationDestination(for: PostViewContainerPayload.self) { postPayload in
              PostViewContainer(post: postPayload.post, sub: postPayload.sub, highlightID: postPayload.highlightID)
                .environmentObject(router)
            }
            .navigationDestination(for: SubViewType.self) { sub in
              switch sub {
              case .posts(let sub):
                SubredditPosts(subreddit: sub)
                  .environmentObject(router)
              case .info(let sub):
                SubredditInfo(subreddit: sub)
                  .environmentObject(router)
              }
            }
            .navigationDestination(for: SubredditPostsContainerPayload.self) { payload in
              SubredditPostsContainer(sub: payload.sub, highlightID: payload.highlightID)
                .environmentObject(router)
            }
            .navigationDestination(for: User.self) { user in
              UserView(user: user)
                .environmentObject(router)
            }
            .environmentObject(router)
        } else {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
            .onAppear {
              Task {
                await redditAPI.fetchMe(force: true)
              }
            }
        }
      }
    }
    .onChange(of: reset) { _ in router.path = NavigationPath() }
  }
}

//struct Me_Previews: PreviewProvider {
//  static var previews: some View {
//    Me()
//  }
//}
