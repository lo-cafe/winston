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

struct PostContent: View, Equatable {
  static func == (lhs: PostContent, rhs: PostContent) -> Bool {
    lhs.post.id == rhs.post.id
  }
  
  @ObservedObject var post: Post
  @ObservedObject var winstonData: PostWinstonData
  var sub: Subreddit
  var forceCollapse: Bool = false
  @State private var collapsed = false
  @Default(.blurPostNSFW) private var blurPostNSFW
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  
  @ObservedObject var avatarCache = Caches.avatars
  @ObservedObject private var videosCache = Caches.videos
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  
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
      
      Text(data.title)
        .fontSize(postsTheme.titleText.size, .semibold)
        .foregroundColor(postsTheme.titleText.color.cs(cs).color())
        .fixedSize(horizontal: false, vertical: true)
        .id("post-title")
        .onAppear { Task { await post.toggleSeen(true) } }
        .listRowInsets(EdgeInsets(top: postsTheme.padding.vertical, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing / 2, trailing: selectedTheme.posts.padding.horizontal))
      
      VStack(spacing: 0) {
        VStack(spacing: selectedTheme.posts.spacing) {
          
          if let extractedMedia = winstonData.extractedMediaForcedNormal {
            MediaPresenter(postDimensions: $winstonData.postDimensionsForcedNormal, controller: nil, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: {}, cornerRadius: selectedTheme.postLinks.theme.mediaCornerRadius, blurPostLinkNSFW: false, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensionsForcedNormal.mediaSize?.width ?? 0, resetVideo: nil)
          }
          
          if data.selftext != "" {

            MD2(winstonData.postBodyAttr == nil ? .str(data.selftext) : .nsAttr(winstonData.postBodyAttr!), onTap: { withAnimation(spring) { collapsed.toggle() } })
              .frame(width: winstonData.postViewBodySize.width, height: winstonData.postViewBodySize.height, alignment: .topLeading)
              .fixedSize()
//              .foregroundColor(postsTheme.bodyText.color.cs(cs).color())
              .allowsHitTesting(!isCollapsed)
          }
        }
        .modifier(AnimatingCellHeight(height: isCollapsed ? 175 : winstonData.postViewBodySize.height + (winstonData.postDimensionsForcedNormal.mediaSize?.height ?? 0), disable: false))
        .fixedSize(horizontal: false, vertical: true)
        .clipped()
        .opacity(isCollapsed ? 0.3 : 1)
        .mask(
          Rectangle()
            .fill(LinearGradient(
              gradient: Gradient(stops: [
                .init(color: Color.black.opacity(isCollapsed ? 0.75 : 1), location: 0),
                .init(color: Color.black.opacity(isCollapsed ? 0 : 1), location: 1)
              ]),
              startPoint: .top,
              endPoint: .bottom
            ))
        )
        .overlay(
          HStack {
            Image(systemName: "eye.fill")
            Text("Tap to expand").allowsHitTesting(false)
          }
            .padding(.top, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(spring) { collapsed.toggle() } }
            .foregroundColor(.accentColor)
            .allowsHitTesting(isCollapsed)
            .opacity(isCollapsed ? 1 : 0)
          , alignment: .bottom
        )
        .nsfw(over18 && blurPostNSFW)
      }
      .id("post-content")
      .listRowInsets(EdgeInsets(top: postsTheme.spacing / 2, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing / 2, trailing: postsTheme.spacing / 2))
      
      BadgeOpt(avatarRequest: winstonData.avatarImageRequest, badgeKit: data.badgeKit, cs: cs, showVotes: false, theme: postsTheme.badge,
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
