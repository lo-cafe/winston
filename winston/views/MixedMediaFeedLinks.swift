//
//  UserSavedLinks.swift
//  winston
//
//  Created by Ethan Bills on 11/16/23.
//

import Foundation
import SwiftUI
import Defaults

struct MixedMediaFeedLinksView: View {
  var mixedMediaLinks: [Either<Post, Comment>]
  @Binding var loadNextData: Bool
  
  @StateObject var user: User
  @State private var contentWidth: CGFloat = 0
  @State private var loadingOverview = true
  @State private var lastItemId: String? = nil
  @Environment(\.useTheme) private var selectedTheme
  @EnvironmentObject private var routerProxy: RouterProxy
  
  @State private var dataTypeFilter: String = "" // Handles filtering for only posts or only comments.
  
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
  
  @ObservedObject var avatarCache = Caches.avatars
  @Environment(\.colorScheme) private var cs

  var body: some View {
    ForEach(Array(mixedMediaLinks.enumerated()), id: \.self.element.hashValue) { i, item in
      VStack(spacing: 0) {
        switch item {
        case .first(let post):
          if let postData = post.data, let winstonData = post.winstonData {
            PostLink(
              id: post.id,
              controller: nil,
              avatarRequest: avatarCache.cache[postData.author_fullname ?? ""]?.data,
//              repostAvatarRequest: getRepostAvatarRequest(post),
              theme: selectedTheme.postLinks,
              showSub: true,
              routerProxy: routerProxy,
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
            .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
            .environmentObject(post)
            .environmentObject(Subreddit(id: postData.subreddit, api: user.redditAPI))
            .environmentObject(winstonData)
          }
        case .second(let comment):
          VStack {
            ShortCommentPostLink(comment: comment)
            if let commentWinstonData = comment.winstonData {
              CommentLink(lineLimit: 3, showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
                .allowsHitTesting(false)
            }
          }
          .padding(.horizontal, 12)
          .padding(.top, 12)
          .padding(.bottom, 10)
          .themedListRowBG()
          .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
      }
      .onAppear {
        if mixedMediaLinks.count > 0 && (Int(Double(mixedMediaLinks.count) * 0.75) == i) {
          loadNextData = true
        }
      }
    }
  }
}
