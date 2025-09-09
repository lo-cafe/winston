//
//  SubredditsStack.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import SwiftUI
import Defaults
import CoreData

struct SubredditsStack: View {
  @State var router: Router
  @Default(.BehaviorDefSettings) private var behaviorDefSettings // handle default feed selection routing
  @Default(.GeneralDefSettings) private var generalDefSettings // handle default feed selection routing
  @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
  @State private var sidebarSize: CGSize = .zero
  @Environment(\.managedObjectContext) private var viewContext  
  @FetchRequest var multis: FetchedResults<CachedMulti>

  init(router: Router) {
    self._router = .init(initialValue: router)

    let fetchRequest: NSFetchRequest<CachedMulti> = CachedMulti.fetchRequest()
    fetchRequest.sortDescriptors = []
    
    let behaviorDefSettings = Defaults[.BehaviorDefSettings]
    if behaviorDefSettings.preferenceDefaultFeed == "multireddit" && !behaviorDefSettings.preferenceDefaultFeedName.isEmpty {
      fetchRequest.predicate = NSPredicate(format: "path = %@", behaviorDefSettings.preferenceDefaultFeedName)
      fetchRequest.fetchLimit = 1
    } else {
      fetchRequest.predicate = NSPredicate(format: "FALSEPREDICATE")
      fetchRequest.fetchLimit = 0
    }
    self._multis = .init(fetchRequest: fetchRequest)
  }
  
  var postContentWidth: CGFloat { .screenW - (!IPAD || columnVisibility == .detailOnly ? 0 : sidebarSize.width) }
  
  @State private var loaded = false
  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      if let redditCredentialSelectedID = generalDefSettings.redditCredentialSelectedID {
        Subreddits(firstDestination: $router.firstSelected, loaded: loaded, currentCredentialID: redditCredentialSelectedID)
          .measure($sidebarSize).id("subreddits-list-\(redditCredentialSelectedID)")
          .attachViewControllerToRouter(tabID: .posts)
      }
    } detail: {
      NavigationStack(path: $router.path) {
        Group {
          if let firstSelected = router.firstSelected {
            switch firstSelected {
            case .reddit(.multiFeed(let multi)):
              MultiPostsView(multi: multi)
                .id("\(multi.id)-multi-first-tab")
                .attachViewControllerToRouter(tabID: .posts)
            case .reddit(.subFeed(let sub)):
              SubredditPosts(subreddit: sub)
                .id("\(sub.id)-sub-first-tab")
            case .reddit(.post(let post)):
              if let sub = post.winstonData?.subreddit {
                PostView(post: post, subreddit: sub)
                  .id("\(post.id)-post-first-tab")
                  .attachViewControllerToRouter(tabID: .posts)
              }
            case .reddit(.user(let user)):
              UserView(user: user)
                .id("\(user.id)-user-first-tab")
                .attachViewControllerToRouter(tabID: .posts)
            default:
              EmptyView()
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
            .attachViewControllerToRouter(tabID: .posts)
          }
        }
        .injectInTabDestinations()
        .task(priority: .background) {
          if !loaded {
            // MARK: Route to default feed
            if behaviorDefSettings.preferenceDefaultFeed != "subList" && router.path.count == 0 { // we are in subList, can ignore

              if behaviorDefSettings.preferenceDefaultFeed == "multireddit" {
                if let multi = multis.first {
                  router.navigateTo(.reddit(.multiFeed(Multi(data: MultiData(entity: multi)))))
                }
              } else {
                let tempSubreddit = Subreddit(id: behaviorDefSettings.preferenceDefaultFeed)
                router.navigateTo(.reddit(.subFeed(tempSubreddit)))
              }
            }

            withAnimation {
              loaded = true
            }
          }
        }
      }
      .environment(\.contentWidth, postContentWidth)
    }
//    .swipeAnywhere()
    .environment(\.contentWidth, postContentWidth)
  }
}
