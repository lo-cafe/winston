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

struct PostContent: View {
  @ObservedObject var post: Post
  var forceCollapse: Bool = false
  @State private var height: CGFloat = 0
  @State private var collapsed = false
  @Default(.blurPostNSFW) private var blurPostNSFW
  @Default(.preferenceShowPostsAvatars) var showPostAvatars
  @Default(.postViewTitleSize) var postViewTitleSize
  @Default(.postViewBodySize) var postViewBodySize
  private var contentWidth: CGFloat { UIScreen.screenWidth - 16 }
  
  var body: some View {
    let isCollapsed = forceCollapse || collapsed
    if let data = post.data {
      let over18 = data.over_18 ?? false
      Group {
        Text(data.title)
          .fontSize(postViewTitleSize, .semibold)
          .fixedSize(horizontal: false, vertical: true)
          .id("post-title")
          .onAppear {
            post.toggleSeen(true)
          }
          .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 6, trailing: 8))
                
        VStack(spacing: 0) {
          VStack(spacing: 12) {
            
            if let extractedMedia = mediaExtractor(post) {
              MediaPresenter(media: extractedMedia, post: post, compact: false, contentWidth: contentWidth)
                .id("media-post-open")
            }
            
            if data.selftext != "" {
              VStack {
                MD(str: data.selftext, fontSize: postViewBodySize)
              }
              .contentShape(Rectangle())
              .onTapGesture { withAnimation(spring) { collapsed.toggle() } }
              .allowsHitTesting(!isCollapsed)
            }
          }
          .fixedSize(horizontal: false, vertical: true)
          .modifier(AnimatingCellHeight(height: isCollapsed ? 75 : height, disable: !forceCollapse && height == 0))
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
          .background(GeometryReader { geo in Color.clear.onAppear {
            if height == 0 && !forceCollapse { height = geo.size.height }
          }})
          .nsfw(over18 && blurPostNSFW)
        }
        .id("post-content")
        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        
        if let fullname = data.author_fullname {
          Badge(showAvatar: showPostAvatars, author: data.author, fullname: fullname, created: data.created)
            .id("post-badge")
            .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 8, trailing: 8))
        }
        
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
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
    } else {
      VStack {
        ProgressView()
          .progressViewStyle(.circular)
          .frame(maxWidth: .infinity, minHeight: UIScreen.screenHeight - 200 )
          .id("post-loading")
      }
    }
  }
}
