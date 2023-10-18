//
//  ShortPostLink.swift
//  winston
//
//  Created by Igor Marcossi on 29/07/23.
//

import SwiftUI
import Defaults

struct ShortPostLink: View {
  var noHPad = false
  var post: Post
  @EnvironmentObject private var routerProxy: RouterProxy
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs: ColorScheme

  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading) {
        Text("\(data.title.escape)")
          .fontSize(18, .semibold)
        Text((data.selftext).md()).lineLimit(2)
          .fontSize(15).opacity(0.75)
        HStack {
          if let fullname = data.author_fullname {
            Badge(cs: cs, routerProxy: routerProxy, showVotes: true, post: post, theme: selectedTheme.postLinks.theme.badge)
//              .equatable()
          }
          Spacer()
          FlairTag(text: "r/\(data.subreddit)", color: .blue)
            .highPriorityGesture(TapGesture().onEnded {
              routerProxy.router.path.append(SubViewType.posts(Subreddit(id: data.subreddit, api: post.redditAPI)))
            })
        }
      }
      .padding(.horizontal, noHPad ? 0 : 16)
      .padding(.vertical, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .themedListRowBG()
      .mask(RR(20, Color.black))
      .onTapGesture {
        routerProxy.router.path.append(PostViewPayload(post: post, postSelfAttr: nil, sub: Subreddit(id: data.subreddit, api: post.redditAPI)))
      }
    }
  }
}
