//
//  DefaultDestinationInjector.swift
//  winston
//
//  Created by Igor Marcossi on 02/09/23.
//

import SwiftUI

struct DefaultDestinationInjector<Content: View>: View {
  @StateObject var routerProxy: RouterProxy
  var content: () -> Content
  var body: some View {
    content()
      .navigationDestination(for: PostViewPayload.self) { postPayload in
        PostView(post: postPayload.post, selfAttr: postPayload.postSelfAttr, subreddit: postPayload.sub, highlightID: postPayload.highlightID)
          .equatable()
          .environmentObject(routerProxy)
      }
      .navigationDestination(for: PostViewContainerPayload.self) { postPayload in
        PostViewContainer(post: postPayload.post, sub: postPayload.sub, highlightID: postPayload.highlightID)
          .environmentObject(routerProxy)
      }
      .navigationDestination(for: SubViewType.self) { sub in
        switch sub {
        case .posts(let sub):
          SubredditPosts(subreddit: sub)
            .environmentObject(routerProxy)
        case .info(let sub):
          SubredditInfo(subreddit: sub)
            .environmentObject(routerProxy)
        }
      }
      .navigationDestination(for: MultiViewType.self) { sub in
        switch sub {
        case .posts(let multi):
          MultiPostsView(multi: multi)
            .environmentObject(routerProxy)
        case .info(_):
          EmptyView()
        }
      }
      .navigationDestination(for: SubredditPostsContainerPayload.self) { payload in
        SubredditPostsContainer(sub: payload.sub, highlightID: payload.highlightID)
          .environmentObject(routerProxy)
      }
      .navigationDestination(for: User.self) { user in
        UserView(user: user)
          .environmentObject(routerProxy)
      }
      .environmentObject(routerProxy)
  }
}
