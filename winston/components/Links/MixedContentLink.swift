//
//  MixedContentLink.swift
//  winston
//
//  Created by Igor Marcossi on 21/11/23.
//

import SwiftUI
import Defaults

struct MixedContentLink: View, Equatable {
  static func == (lhs: MixedContentLink, rhs: MixedContentLink) -> Bool {
    lhs.content == rhs.content && lhs.theme == rhs.theme
  }
  
  var content: Either<Post, Comment>
  var theme: SubPostsListTheme
  
  @Default(.PostLinkDefSettings) private var postLinkDefSettings
  @Default(.CommentLinkDefSettings) private var commentLinkDefSettings
  @Environment(\.contentWidth) private var contentWidth
  
  var body: some View {
    switch content {
    case .first(let post):
      if let winstonData = post.winstonData, let postSub = winstonData.subreddit {
        PostLink(id: post.id, theme: theme, showSub: true, contentWidth: contentWidth, defSettings: postLinkDefSettings)
          .environmentObject(post)
          .environmentObject(postSub)
          .environmentObject(winstonData)
      }
    case .second(let comment):
      VStack {
        ShortCommentPostLink(comment: comment)
          .allowsHitTesting(false)
        if let commentWinstonData = comment.winstonData {
          CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
            .allowsHitTesting(false)
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        if let data = comment.data, let link_id = data.link_id, let subID = data.subreddit {
          Nav.to(.reddit(.postHighlighted(Post(id: link_id, subID: subID), comment.id)))
        }
      }
      .padding(.horizontal, 12)
      .padding(.top, 12)
      .padding(.bottom, 10)
      .background(PostLinkBG(theme: theme, stickied: false, secondary: false).equatable())
      .mask(RR(theme.theme.cornerRadius, Color.black).equatable())
    }
  }
}
