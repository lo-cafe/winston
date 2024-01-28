//
//  PostContent.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import SwiftUI
import Defaults
import AVKit
import AVFoundation
import MarkdownUI

struct PostContent: View, Equatable {
  static func == (lhs: PostContent, rhs: PostContent) -> Bool {
    lhs.post.id == rhs.post.id
  }
  
  var post: Post
  var winstonData: PostWinstonData
  var sub: Subreddit
  var forceCollapse: Bool = false
  @State private var collapsed = false
  @Default(.PostPageDefSettings) private var defSettings
  @Environment(\.useTheme) private var selectedTheme
  
  var contentWidth: CGFloat { .screenW - (selectedTheme.posts.padding.horizontal * 2) }
  
  func openSubreddit() {
    if let subName = post.data?.subreddit {
      Nav.to(.reddit(.subFeed(Subreddit(id: subName))))
    }
  }
  
  var body: some View {
    let postsTheme = selectedTheme.posts
    let isCollapsed = forceCollapse || collapsed
    let data = post.data ?? emptyPostData
    let over18 = data.over_18 ?? false
    Group {
      
      if post.data == nil {
        VStack {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: .screenH - 200 )
            .id("post-loading")
        }
      }
      
      Group {
        Text(data.title)
          .fontSize(postsTheme.titleText.size, .semibold)
          .foregroundColor(postsTheme.titleText.color())
          .fixedSize(horizontal: false, vertical: true)
          .id("post-title")
          .onAppear { Task { await post.toggleSeen(true) } }
          .listRowInsets(EdgeInsets(top: postsTheme.padding.vertical, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing / 2, trailing: selectedTheme.posts.padding.horizontal))
        
        Group {
          if !isCollapsed {
            VStack(spacing: 0) {
              VStack(spacing: selectedTheme.posts.spacing) {
                if let extractedMedia = winstonData.extractedMediaForcedNormal {
                  MediaPresenter(winstonData: winstonData, fullPage: true, controller: nil, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: {}, cornerRadius: selectedTheme.postLinks.theme.mediaCornerRadius, blurPostLinkNSFW: defSettings.blurNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensionsForcedNormal.mediaSize?.width ?? 0, maxMediaHeightScreenPercentage: Defaults[.PostLinkDefSettings].maxMediaHeightScreenPercentage, resetVideo: nil)
                }
                
                if !data.selftext.isEmpty {
                  Markdown(MarkdownUtil.formatForMarkdown(data.selftext))
                    .markdownTheme(.winstonMarkdown(fontSize: selectedTheme.posts.bodyText.size, lineSpacing: selectedTheme.posts.linespacing))
                }
              }
              .nsfw(over18 && defSettings.blurNSFW)
            }
          } else {
            Text("*Collapsed...*").foregroundStyle(.secondary).font(.caption)
          }
        }
        .id("post-content")
        .listRowInsets(EdgeInsets(top: postsTheme.spacing / 2, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing / 2, trailing: postsTheme.spacing / 2))
      }
      .contentShape(Rectangle())
      .onTapGesture { withAnimation(.smooth) { collapsed.toggle() }}
      
      BadgeOpt(avatarRequest: winstonData.avatarImageRequest, badgeKit: data.badgeKit, showVotes: false, theme: postsTheme.badge,
               openSub: openSubreddit, subName: data.subreddit)
      .id("post-badge")
      .listRowInsets(EdgeInsets(top: postsTheme.spacing / 2, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing * 0.75, trailing: postsTheme.padding.horizontal))
      
      SubsNStuffLine()
        .id("post-flair-divider")
        .listRowInsets(EdgeInsets(top: 0, leading: postsTheme.padding.horizontal, bottom: postsTheme.commentsDistance / 2, trailing: postsTheme.padding.horizontal))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .multilineTextAlignment(.leading)
  }
}
