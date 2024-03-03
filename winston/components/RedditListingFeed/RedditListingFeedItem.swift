//
//  RedditListingFeedItem.swift
//  winston
//
//  Created by Igor Marcossi on 03/03/24.
//

import SwiftUI
import Defaults

struct RedditListingFeedItem<S: Sorting>: View {
  var el: RedditEntityType
  var i: Int
  var subreddit: Subreddit?
  var isThereDivider: Bool
  var showSubInPosts: Bool
  var itemsManager: FeedItemsManager<S>
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  @Default(.SubredditFeedDefSettings) private var subredditFeedDefSettings
  @Default(.PostLinkDefSettings) private var postLinkDefSettings
  @Default(.SubredditFeedDefSettings) private var feedDefSettings
  
    var body: some View {
      Group {
        switch el {
        case .post(let post):
          if let winstonData = post.winstonData, let sub = winstonData.subreddit ?? subreddit {
            let isThereDivider = selectedTheme.postLinks.divider.style != .no
            let paddingH = selectedTheme.postLinks.theme.outerHPadding
            let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
            PostLink(id: post.id, theme: selectedTheme.postLinks, showSub: showSubInPosts, compactPerSubreddit: feedDefSettings.compactPerSubreddit[sub.id], contentWidth: contentWidth, defSettings: postLinkDefSettings)
              .environment(\.contextPost, post)
              .environment(\.contextSubreddit, sub)
              .environment(\.contextPostWinstonData, winstonData)
              .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
            
            if isThereDivider && (i != (itemsManager.entities.count - 1)) {
              NiceDivider(divider: selectedTheme.postLinks.divider)
//                          .id("\(post.id)-divider")
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
          }
        case .subreddit(let sub): SubredditLink(sub: sub)
        case .multi(_): EmptyView()
        case .comment(let comment):
          VStack {
            ShortCommentPostLink(comment: comment)
              .padding()
            if let commentWinstonData = comment.winstonData {
              CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
            }
          }
          .background(PostLinkBG(theme: selectedTheme.postLinks.theme, stickied: false, secondary: false))
          .mask(RR(selectedTheme.postLinks.theme.cornerRadius, Color.black))
          .allowsHitTesting(false)
          .onTapGesture {
            if let data = comment.data, let link_id = data.link_id, let subID = data.subreddit {
              Nav.to(.reddit(.postHighlighted(Post(id: link_id, subID: subID), comment.id)))
            }
          }
        case .user(let user): UserLink(user: user)
        case .message(let message):
          let isThereDivider = selectedTheme.postLinks.divider.style != .no
          let paddingH = selectedTheme.postLinks.theme.outerHPadding
          let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
          MessageLink(message: message)
            .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
          
          if isThereDivider && (i != (itemsManager.entities.count - 1)) {
            NiceDivider(divider: selectedTheme.postLinks.divider)
//                        .id("\(message.id)-divider")
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
        }
      }
      .onAppear { Task { await itemsManager.iAppeared🥳(entity: el, index: i) } }
      .onDisappear { Task { await itemsManager.imGone🙁(entity: el, index: i) } }
    }
}
