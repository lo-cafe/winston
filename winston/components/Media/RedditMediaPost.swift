//
//  RedditMediaPost.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import SwiftUI
import Combine

struct RedditMediaPost: View {
  var entity: RedditEntityType
  static let height: CGFloat = 88
  
  var body: some View {
    HStack(spacing: 16) {
        switch entity {
        case .comment(let comment):
            //            ShortCommentPostLink(comment: comment)
          if let commentWinstonData = comment.winstonData {
            CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
              .padding(.vertical, 8)
          }
        case .post(let post):
          ShortPostLink(noHPad: true, post: post)
        case .user(let user):
          UserLinkContainer(noHPad: true, user: user)
        case .subreddit(let subreddit):
          SubredditLinkContainer(sub: subreddit)
        }
    }
    .frame(maxWidth: .infinity, minHeight: RedditMediaPost.height, maxHeight: RedditMediaPost.height)
    .padding(.horizontal, 8)
    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.primary.opacity(0.1)))
  }
}
