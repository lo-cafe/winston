//
//  injectInTabDestinations.swift
//  winston
//
//  Created by Igor Marcossi on 02/09/23.
//

import SwiftUI
import Defaults

struct AttachViewControllerToRouterModifier: ViewModifier {
  @Default(.BehaviorDefSettings) private var behaviorDefSettings
  
  func body(content: Content) -> some View {
    content
      .background { AttachViewControllerToRouterView(disable: !behaviorDefSettings.enableSwipeAnywhere) }
  }
}

extension View {
  func attachViewControllerToRouter() -> some View {
    self.modifier(AttachViewControllerToRouterModifier())
  }
  
  func injectInTabDestinations() -> some View {
    self
//      .attachViewControllerToRouter()
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


fileprivate struct AttachViewControllerToRouterView: UIViewRepresentable {
  var disable: Bool
  func makeUIView(context: Context) -> some UIView {
    return UIView()
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    DispatchQueue.main.async {
      if let controller = uiView.parentViewController {
        Nav.router.navController.controller = controller
      }
      if disable {
        Nav.router.navController.removeGestureFromViews()
      } else {
        Nav.router.navController.addGestureToViews()
      }
    }
  }
}

fileprivate extension UIView {
  var parentViewController: UIViewController? {
    sequence(first: self) {
      $0.next
    }.first(where: { $0 is UIViewController }) as? UIViewController
  }
}
