//
//  injectInTabDestinations.swift
//  winston
//
//  Created by Igor Marcossi on 02/09/23.
//

import SwiftUI

extension View {
  func injectInTabDestinations() -> some View {
    self
      .navigationDestination(for: Router.NavDest.self, destination: { dest in
        switch dest {
        case .reddit(let reddDest):
          switch reddDest {
          case .post(let (post)):
            if let sub = post.winstonData?.subreddit {
              PostView(post: post, subreddit: sub)
            }
          case .postHighlighted(let post, let highlightID):
            if let sub = post.winstonData?.subreddit {
              PostView(post: post, subreddit: sub, highlightID: highlightID)
            } else {
              Text("Mininu")
            }
          case .subFeed(let sub):
            SubredditPosts(subreddit: sub)
          case .subInfo(let sub):
            SubredditInfo(subreddit: sub)
          case .multiFeed(let multi):
            MultiPostsView(multi: multi)
          case .multiInfo(_):
            EmptyView()
          case .user(let user):
            UserView(user: user)
          }
        case .setting(let settingsDest):
          switch settingsDest {
            case .general:
              GeneralPanel()
            case .behavior:
              BehaviorPanel()
            case .appearance:
              AppearancePanel()
            case .credentials:
              CredentialsPanel()
            case .about:
              AboutPanel()
            case .commentSwipe:
              CommentSwipePanel()
            case .postSwipe:
              PostSwipePanel()
            case .accessibility:
              AccessibilityPanel()
            case .postFontSettings:
              PostFontSettings()
            case .filteredSubreddits:
              FilteredSubredditsSettings()
            case .faq:
              FAQPanel()
            case .themes:
              ThemesPanel()
            case .themeStore:
              ThemeStore()
            case .appIcon:
              AppIconSetting()
            }
        }
      })
  }
}
