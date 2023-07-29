//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import VideoPlayer
import CoreMedia
import Defaults
import AVKit

struct FlairTag: View {
  var text: String
  var blue = false
  var body: some View {
    Text(text)
      .fontSize(13)
      .padding(.horizontal, 9)
      .padding(.vertical, 2)
      .background(Capsule(style: .continuous).fill((blue ? Color.blue : Color.secondary).opacity(0.2)))
      .foregroundColor(.primary.opacity(0.5))
      .fixedSize()
  }
}

let POSTLINK_INNER_H_PAD: CGFloat = 16

struct PostLink: View {
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.preferenceShowPostsAvatars) var preferenceShowPostsAvatars
  @ObservedObject var post: Post
  @ObservedObject var sub: Subreddit
  var showSub = false
  var scrollPos: CGFloat?
  @State var contentWidth: CGFloat = .zero
  @State var playingVideo = true
  @State var offsetX: CGFloat = 0
  @State private var time: CMTime = .zero
  @State private var fullscreen = false
  @State private var aboveAll = 0
  @State private var pressing = false
  @State private var openedPost = false
  @State private var openedSub = false
  @State private var dragging = false
  @State var redrawPreview = false
  
  @GestureState private var isPressing = false
  @GestureState private var dragX: CGFloat = 0
  
  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading, spacing: 8) {
        VStack(alignment: .leading, spacing: 12) {
          Text(data.title.stringByDecodingHTMLEntities)
            .fontSize(17, .medium)
            .allowsHitTesting(false)
          
          let imgPost = data.is_gallery == true || data.url.hasSuffix("jpg") || data.url.hasSuffix("png")
          
          if let media = data.secure_media {
            switch media {
            case .first(let datas):
              if let url = datas.reddit_video?.fallback_url {
                VideoPlayerPost(post: post, sharedVideo: SharedVideo(player: AVPlayer(url:  URL(string: url)!)))
              }
            case .second(_):
              EmptyView()
            }
          }
          
          if imgPost {
            ImageMediaPost(post: post)
          } else if data.selftext != "" {
//            MD(str: data.selftext, lineLimit: 3)
            Text(data.selftext.md()).lineLimit(3)
              .fontSize(15)
              .opacity(0.75)
              .allowsHitTesting(false)
          }
        }
        .zIndex(1)
        
        if let hint = data.post_hint, hint == "link" {
          PreviewLink(data.url)
        }
        
        HStack(spacing: 0) {
          if let link_flair_text = data.link_flair_text {
            if showSub {
              Button {
                openedSub = true
              } label: {
                FlairTag(text: "r/\(sub.data?.display_name ?? "Error")", blue: true)
              }
            }
            
            Rectangle()
              .fill(.primary.opacity(0.05))
              .frame(maxWidth: .infinity, maxHeight: 1)
              .allowsHitTesting(false)
            
            FlairTag(text: link_flair_text)
              .allowsHitTesting(false)
          }
          
          if !showSub {
            Rectangle()
              .fill(.primary.opacity(0.05))
              .frame(maxWidth: .infinity, maxHeight: 1)
              .allowsHitTesting(false)
          }
        }
        .padding(.horizontal, 2)
        
        HStack {
          if let fullname = data.author_fullname {
            Badge(showAvatar: preferenceShowPostsAvatars, author: data.author, fullname: fullname, created: data.created, extraInfo: ["message.fill":"\(data.num_comments)"])
          }
          
          Spacer()
          
          HStack(alignment: .center, spacing: 0) {
            MasterButton(icon: "arrow.up", mode: .subtle, color: .white, colorHoverEffect: .animated, textColor: data.likes != nil && data.likes! ? .orange : .gray, textSize: 22, proportional: .circle) {
              Task {
                _ = await post.vote(action: .up)
              }
            }
//            .shrinkOnTap()
            .padding(.all, -8)
            
            let downup = Int(data.ups - data.downs)
            Text(formatBigNumber(downup))
              .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
              .fontSize(16, .semibold)
              .padding(.horizontal, 12)
              .viewVotes(data.ups, data.downs)
              .zIndex(10)
            
            MasterButton(icon: "arrow.down", mode: .subtle, color: .white, colorHoverEffect: .animated, textColor: data.likes != nil && !data.likes! ? .blue : .gray, textSize: 22, proportional: .circle) {
              Task {
                _ = await post.vote(action: .down)
              }
            }
//            .shrinkOnTap()
            .padding(.all, -8)
          }
          .fontSize(22, .medium)
        }
      }
      .background( GeometryReader { geo in Color.clear .onAppear { contentWidth = geo.size.width } } )
      .padding(.horizontal, preferenceShowPostsCards ? POSTLINK_INNER_H_PAD : 0)
      .padding(.vertical, preferenceShowPostsCards ? 14 : 6)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        NavigationLink(destination: PostView(post: post, subreddit: sub), isActive: $openedPost, label: { EmptyView() }).buttonStyle(EmptyButtonStyle()).opacity(0).allowsHitTesting(false)
      )
      .if(preferenceShowPostsCards) { view in
        view
          .background(RR(20, .listBG).allowsHitTesting(false))
          .mask(RR(20, .black))
      }
      .compositingGroup()
      .opacity((data.winstonSeen ?? false) ? 0.65 : 1)
      .contentShape(Rectangle())
      .swipyUI(onTap: {
        openedPost = true
      }, secondActionIcon: (data.winstonSeen ?? false) ? "eye.slash.fill" : "eye.fill",
      leftActionHandler: {
        Task {
          _ = await post.vote(action: .down)
        }
      }, rightActionHandler: {
        Task {
          _ = await post.vote(action: .up)
        }
      }, secondActionHandler: {
        withAnimation {
          post.toggleSeen(optimistic: true)
        }
      })
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
      .zIndex(Double(aboveAll))
    } else {
      Text("Oops something went wrong")
    }
  }
}

struct EmptyButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
  }
}
