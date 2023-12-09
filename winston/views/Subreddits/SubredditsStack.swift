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
  @ObservedObject var router: Router
  @Default(.preferenceDefaultFeed) private var preferenceDefaultFeed // handle default feed selection routing
  @Default(.redditCredentialSelectedID) private var redditCredentialSelectedID
  @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
  @State private var sidebarSize: CGSize = .zero
  
  var postContentWidth: CGFloat { UIScreen.screenWidth - (!IPAD || columnVisibility != .doubleColumn ? 0 : sidebarSize.width) }
  
  @State private var loaded = false
  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      if let redditCredentialSelectedID = redditCredentialSelectedID {
        Subreddits(selectedSub: $router.firstSelected, loaded: loaded, currentCredentialID: redditCredentialSelectedID)
          .measure($sidebarSize)
      }
    } detail: {
      NavigationStack(path: $router.path) {
        DefaultDestinationInjector {
          if let firstSelected = router.firstSelected {
            switch firstSelected {
            case .multi(let multi):
              MultiPostsView(multi: multi)
                .id("\(multi.id)-multi-first-tab")
            case .sub(let sub):
              SubredditPosts(subreddit: sub)
                .id("\(sub.id)-sub-first-tab")
            case .post(let payload):
              PostView(post: payload.post, subreddit: payload.sub)
                .id("\(payload.post.id)-post-first-tab")
            case .user(let user):
              UserView(user: user)
                .id("\(user.id)-user-first-tab")
            }
          } else {
            VStack(spacing: 24) {
              Image(.winstonEyes)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
              VStack {
                Text("Meow, I mean...")
                  .opacity(0.38)
                  .fontSize(24, .bold)
                Text("Where are the subs?")
                  .opacity(0.35)
              }
            }
          }
        }
        .task(priority: .background) {
          if !loaded {
            // MARK: Route to default feed
            if preferenceDefaultFeed != "subList" && router.path.count == 0 { // we are in subList, can ignore
              let tempSubreddit = Subreddit(id: preferenceDefaultFeed, api: RedditAPI.shared)
              router.navigateTo(.reddit(.subFeed(tempSubreddit)))
            }
            
            _ = await RedditAPI.shared.fetchSubs()
            _ = await RedditAPI.shared.fetchMyMultis()
            withAnimation {
              loaded = true
            }
          }
        }
      }
      .environment(\.contentWidth, postContentWidth)
    }
    .swipeAnywhere()
    .environment(\.contentWidth, postContentWidth)
    .onChange(of: reset) { _ in
      withAnimation {
        router.resetNavPath()
        router.firstSelected = nil
      }
    }
  }
}
