//
//  SubredditsStack.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI
import Defaults

struct SubredditsStack: View {
  var reset: Bool
  @StateObject var router: Router
  @Default(.preferenceDefaultFeed) private var preferenceDefaultFeed // handle default feed selection routing
  @EnvironmentObject private var redditAPI: RedditAPI
  @State private var loaded = false
  var body: some View {
    NavigationStack(path: $router.path) {
      DefaultDestinationInjector(routerProxy: RouterProxy(router)) {
        Subreddits(loaded: loaded, routerProxy: RouterProxy(router))
          .equatable()
      }
      .task {
        if !loaded {
          // MARK: Route to default feed
          if preferenceDefaultFeed != "subList" && router.path.count == 0 { // we are in subList, can ignore
            let tempSubreddit = Subreddit(id: preferenceDefaultFeed, api: redditAPI)
            router.path.append(SubViewType.posts(tempSubreddit))
          }
          
          _ = await redditAPI.fetchSubs()
          _ = await redditAPI.fetchMyMultis()
          withAnimation {
            loaded = true
          }
        }
      }
      .onChange(of: reset) { _ in
        router.path.removeLast(router.path.count)
      }
    }
    .swipeAnywhere(routerContainer: SwipeAnywhereRouterContainer(router))
    .animation(.default, value: router.path)
  }
}
