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
  
  var contentWidth: CGFloat { UIScreen.screenWidth - 16 }
  
  var body: some View {
    if let data = post.data {
      Group {
        Text(data.title)
          .fontSize(20, .semibold)
          .fixedSize(horizontal: false, vertical: true)
          .id("post-title")
          .onAppear {
            post.toggleSeen(true)
          }
          .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 6, trailing: 8))
        
        let imgPost = data.is_gallery == true || data.url.hasSuffix("jpg") || data.url.hasSuffix("png") || data.url.hasSuffix("webp")
        
        if let media = data.secure_media {
          switch media {
          case .first(let datas):
            if let url = datas.reddit_video.hls_url, let rootURL = rootURL(url) {
              VideoPlayerPost(post: post, overrideWidth: UIScreen.screenWidth - 16, sharedVideo: SharedVideo(url: rootURL))
                .id("post-video-player")
                .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
            }
          case .second(_):
            EmptyView()
              .id("post-video-player")
          }
        }
        
        if imgPost {
          ImageMediaPost(prefix: "postView", post: post, contentWidth: contentWidth)
            .id("post-image")
            .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        }
        
        if !data.url.isEmpty && !data.is_self && !(data.is_video ?? false) && !(data.is_gallery ?? false) && data.post_hint != "image" {
          PreviewLink(data.url, contentWidth: contentWidth, media: data.secure_media)
            .id("post-link-preview")
            .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        }
        
        if data.selftext != "" {
          MD(str: data.selftext)
            .id("post-text")
            .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
        }
        
        if let fullname = data.author_fullname {
          Badge(author: data.author, fullname: fullname, created: data.created)
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
