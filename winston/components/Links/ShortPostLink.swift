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
  @Environment(\.useTheme) private var selectedTheme

  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading) {
        Text("\(data.title.escape)")
          .fontSize(18, .semibold)
        Text((data.selftext).md()).lineLimit(2)
          .fontSize(15).opacity(0.75)
        HStack {
//          if let fullname = data.author_fullname {
            Badge(showVotes: true, post: post, theme: selectedTheme.postLinks.theme.badge)
//              .equatable()
//          }
          Spacer()
          Tag(text: "r/\(data.subreddit)", color: selectedTheme.postLinks.theme.badge.subColor())
            .highPriorityGesture(TapGesture().onEnded {
              Nav.to(.reddit(.subFeed(Subreddit(id: data.subreddit))))
            })
        }
      }
      .padding(.horizontal, noHPad ? 0 : 16)
      .padding(.vertical, 14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .themedListRowLikeBG()
      .mask(RR(20, Color.black))
      .onTapGesture { Nav.to(.reddit(.post(post))) }
    }
  }
}
