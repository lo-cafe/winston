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
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactMode) private var compactMode
  @Default(.showVotes) private var showVotes
  @Default(.showSelfText) private var showSelfText
  @Default(.thumbnailPositionRight) private var thumbnailPositionRight
  @Default(.voteButtonPositionRight) private var voteButtonPositionRight
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  @Default(.showUpvoteRatio) private var showUpvoteRatio
  @Default(.showSubsAtTop) private var showSubsAtTop
  @Default(.showTitleAtTop) private var showTitleAtTop
  @Default(.showSelfPostThumbnails) private var showSelfPostThumbnails
  @Environment(\.contentWidth) private var contentWidth
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    switch content {
    case .first(let post):
      if let winstonData = post.winstonData, let postSub = winstonData.subreddit {
        PostLink(
          id: post.id,
          controller: nil,
          theme: theme,
          showSub: true,
          contentWidth: contentWidth,
          blurPostLinkNSFW: blurPostLinkNSFW,
          postSwipeActions: postSwipeActions,
          showVotes: showVotes,
          showSelfText: showSelfText,
          readPostOnScroll: readPostOnScroll,
          hideReadPosts: hideReadPosts,
          showUpvoteRatio: showUpvoteRatio,
          showSubsAtTop: showSubsAtTop,
          showTitleAtTop: showTitleAtTop,
          compact: compactMode,
          thumbnailPositionRight: thumbnailPositionRight,
          voteButtonPositionRight: voteButtonPositionRight,
          showSelfPostThumbnails: showSelfPostThumbnails,
          cs: cs
        )
        .environmentObject(post)
        .environmentObject(postSub)
        .environmentObject(winstonData)
      }
    case .second(let comment):
      VStack {
        ShortCommentPostLink(comment: comment)
        if let commentWinstonData = comment.winstonData {
          CommentLink(lineLimit: 3, showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
        }
      }
      .padding(.horizontal, 12)
      .padding(.top, 12)
      .padding(.bottom, 10)
      .background(PostLinkBG(theme: theme, stickied: false, secondary: false, cs: cs).equatable())
      .mask(RR(theme.theme.cornerRadius, Color.black).equatable())
    }
  }
}
