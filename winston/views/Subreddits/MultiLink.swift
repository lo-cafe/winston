//
//  MultiLink.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import SwiftUI
import Popovers

struct MultiLink: View {
  var multi: MultiData
  var routerProxy: RouterProxy
  
  
  var body: some View {
    Menu {
      if let subs = multi.subreddits {
        ForEach(subs) { sub in
          if let data = sub.data {
            SubItemButton(sub: Subreddit(data: data, api: RedditAPI.shared))
          }
        }
      }
    } label: {
      VStack(spacing: 10) {
        if let imgLink = multi.icon_url, let imgURL = URL(string: imgLink) {
          URLImage(url: imgURL)
            .scaledToFill()
            .frame(width: 72, height: 72)
            .mask(Circle())
        }
        Text(multi.display_name)
          .foregroundColor(.primary)
          .fontSize(15, .medium)
      }
      .multilineTextAlignment(.center)
      .contentShape(Rectangle())
    } primaryAction: {
      routerProxy.router.path.append(MultiViewType.posts(Multi(data: multi, api: RedditAPI.shared)))
    }
  }
}
