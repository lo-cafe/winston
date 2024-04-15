//
//  RedditEntityView.swift
//  winston
//
//  Created by Igor Marcossi on 14/04/24.
//

import SwiftUI
import Defaults

struct RedditEntityView: View, Equatable {
    static func == (lhs: RedditEntityView, rhs: RedditEntityView) -> Bool {
        lhs.entity == rhs.entity &&
        lhs.subreddit == rhs.subreddit &&
        lhs.isLastItem == rhs.isLastItem &&
        lhs.showSubInPosts == rhs.showSubInPosts
    }
    
    var entity: RedditEntityType
    var subreddit: Subreddit?
    var isLastItem: Bool
    var showSubInPosts: Bool
    
    @Environment(\.useTheme) private var selectedTheme
    @Environment(\.contentWidth) private var contentWidth
    @Default(.PostLinkDefSettings) private var postLinkDefSettings
    @Default(.SubredditFeedDefSettings) private var feedDefSettings
    
    var body: some View {
        let isThereDivider = selectedTheme.postLinks.divider.style != .no
        let paddingH = selectedTheme.postLinks.theme.outerHPadding
        let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
        switch entity {
        case .post(let post):
            if let winstonData = post.winstonData, let sub = winstonData.subreddit ?? subreddit {
                PostLink(
                    id: post.id,
                    theme: selectedTheme.postLinks, 
                    showSub: showSubInPosts, 
                    compactPerSubreddit: feedDefSettings.compactPerSubreddit[sub.id], 
                    contentWidth: contentWidth, 
                    defSettings: postLinkDefSettings
                )
                    .environment(\.contextPost, post)
                    .environment(\.contextSubreddit, sub)
                    .environment(\.contextPostWinstonData, winstonData)
                    .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
                
                if isThereDivider && !isLastItem {
                    NiceDivider(divider: selectedTheme.postLinks.divider)
                        .id("\(post.id)-divider")
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
        case .subreddit(let sub): SubredditLink(sub: sub)
        case .multi(_): EmptyView()
        case .comment(let comment):
            VStack(spacing: 8) {
                ShortCommentPostLink(comment: comment)
                    .padding(.horizontal, 12)
                if let commentWinstonData = comment.winstonData {
                    CommentLink(showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
                }
            }
            .padding(.vertical, 12)
            .background(PostLinkBG(theme: selectedTheme.postLinks.theme, stickied: false, secondary: false))
            .mask(RR(selectedTheme.postLinks.theme.cornerRadius, Color.black))
            .allowsHitTesting(false)
            .contentShape(Rectangle())
            .onTapGesture {
                if let data = comment.data, let link_id = data.link_id, let subID = data.subreddit {
                    Nav.to(.reddit(.postHighlighted(Post(id: link_id, subID: subID), comment.id)))
                }
            }
            .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
        case .user(let user): UserLink(user: user)
        case .message(let message):
            let isThereDivider = selectedTheme.postLinks.divider.style != .no
            let paddingH = selectedTheme.postLinks.theme.outerHPadding
            let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
            MessageLink(message: message)
                .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
            
            if isThereDivider && !isLastItem {
                NiceDivider(divider: selectedTheme.postLinks.divider)
                    .id("\(message.id)-divider")
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}
