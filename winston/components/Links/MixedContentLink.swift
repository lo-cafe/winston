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
        PostLink(id: post.id, theme: theme, showSub: true, compactPerSubreddit: nil, contentWidth: contentWidth, defSettings: postLinkDefSettings)
          .environment(\.contextPost, post)
          .environment(\.contextSubreddit, postSub)
          .environment(\.contextPostWinstonData, winstonData)
      }
    case .second(let comment):
      VStack {
        ShortCommentPostLink(comment: comment)
          .padding()
        if let commentWinstonData = comment.winstonData {
          CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
        }
      }
      .background(PostLinkBG(theme: theme.theme, stickied: false, secondary: false))
      .mask(RR(theme.theme.cornerRadius, Color.black))
    }
  }
}
