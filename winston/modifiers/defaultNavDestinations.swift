//
//  defaultNavDestinations.swift
//  winston
//
//  Created by Igor Marcossi on 08/08/23.
//

import SwiftUI

extension View {
  func defaultNavDestinations(_ router: Router) -> some View {
    return self
      .navigationDestination(for: PostViewPayload.self) { postPayload in
        PostView(post: postPayload.post, selfAttr: postPayload.postSelfAttr, subreddit: postPayload.sub, highlightID: postPayload.highlightID)
          .equatable()
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
      .navigationDestination(for: MultiViewType.self) { sub in
        switch sub {
        case .posts(let multi):
          MultiPostsView(multi: multi)
            .environmentObject(router)
        case .info(_):
          EmptyView()
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
  }
}
