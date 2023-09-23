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
  var selfAttr: AttributedString? = nil
  var sub: Subreddit
  var forceCollapse: Bool = false
  @State private var size: CGSize = .zero
  @State private var collapsed = false
  @Default(.blurPostNSFW) private var blurPostNSFW
  @EnvironmentObject private var routerProxy: RouterProxy
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  
  var contentWidth: CGFloat { UIScreen.screenWidth - (selectedTheme.posts.padding.horizontal * 2) }
  
  var body: some View {
    let postsTheme = selectedTheme.posts
    let isCollapsed = forceCollapse || collapsed
    let data = post.data ?? emptyPostData
    let over18 = data.over_18 ?? false
    Group {
      
      if post.data.isNil {
        VStack {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
            .id("post-loading")
        }
      }
      
      Text(data.title)
        .fontSize(postsTheme.titleText.size, .semibold)
        .foregroundColor(postsTheme.titleText.color.cs(cs).color())
        .fixedSize(horizontal: false, vertical: true)
        .id("post-title")
        .onAppear {
          Task {
            await post.toggleSeen(true)
          }
        }
        .listRowInsets(EdgeInsets(top: postsTheme.padding.vertical, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing / 2, trailing: selectedTheme.posts.padding.horizontal))
      
      VStack(spacing: 0) {
        VStack(spacing: selectedTheme.posts.spacing) {
          
          if let extractedMedia = post.winstonData?.winstonExtractedMedia {
            MediaPresenter(media: extractedMedia, post: post, compact: false, contentWidth: contentWidth)
              .id("media-post-open")
          }
          
          if data.selftext != "" {
            VStack {
              MD(selfAttr.isNil ? .str(data.selftext) : .attr(selfAttr!), fontSize: postsTheme.bodyText.size)
                .foregroundColor(postsTheme.bodyText.color.cs(cs).color())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(spring) { collapsed.toggle() } }
            .allowsHitTesting(!isCollapsed)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
        .measure($size)
        .modifier(AnimatingCellHeight(height: isCollapsed ? 75 : size.height, disable: !forceCollapse && size.height == 0))
        .clipped()
        .opacity(isCollapsed ? 0.3 : 1)
        .mask(
          Rectangle()
            .fill(LinearGradient(
              gradient: Gradient(stops: [
                .init(color: Color.black.opacity(1), location: 0),
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(spring) { collapsed.toggle() } }
            .foregroundColor(.blue)
            .allowsHitTesting(isCollapsed)
            .opacity(isCollapsed ? 1 : 0)
          , alignment: .bottom
        )
        .nsfw(over18 && blurPostNSFW)
      }
      .id("post-content")
      .listRowInsets(EdgeInsets(top: postsTheme.spacing / 2, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing / 2, trailing: postsTheme.spacing / 2))
      
      if let fullname = data.author_fullname {
        Badge(author: data.author, fullname: fullname, created: data.created, theme: postsTheme.badge)
          .equatable()
          .id("post-badge")
          .listRowInsets(EdgeInsets(top: postsTheme.spacing / 2, leading: postsTheme.padding.horizontal, bottom: postsTheme.spacing * 0.75, trailing: postsTheme.padding.horizontal))
      }
      
      
      SubsNStuffLine(showSub: true, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
        .equatable()
        .id("post-flair-divider")
        .listRowInsets(EdgeInsets(top: 0, leading: postsTheme.padding.horizontal, bottom: postsTheme.commentsDistance / 2, trailing: postsTheme.padding.horizontal))
      
      HStack(spacing: 0) {
        if let link_flair_text = data.link_flair_text {
          Rectangle()
            .fill(.primary.opacity(0.1))
            .frame(maxWidth: .infinity, maxHeight: 1)
          
          Text(link_flair_text)
            .fontSize(13)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule(style: .continuous).fill(.secondary.opacity(0.25)))
            .foregroundColor(.primary.opacity(0.5))
            .fixedSize()
        }
        Rectangle()
          .fill(.primary.opacity(0.1))
          .frame(maxWidth: .infinity, maxHeight: 1)
      }
      .padding(.horizontal, 2)
      .id("post-flair-divider")
      .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    //      .foregroundColor(.primary)
    .multilineTextAlignment(.leading)
  }
}
