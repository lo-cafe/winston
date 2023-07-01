//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import SDWebImageSwiftUI
import VideoPlayer
import CoreMedia

struct PostLink: View {
  @State var post: Post
  var sub: Subreddit
  @State var contentWidth: CGFloat = .zero
  @State var playingVideo = true
  @State private var time: CMTime = .zero
  @State private var fullscreen = false
  @State private var aboveAll = 0
  @EnvironmentObject var namespaceWrapper: NamespaceWrapper
  @EnvironmentObject var lightBoxType: ContentLightBox
  
  var body: some View {
    NavigationLink { PostView(post: post, subreddit: sub) } label: {
      if let data = post.data {
        VStack(alignment: .leading, spacing: 8) {
          VStack(alignment: .leading, spacing: 12) {
            Text(data.title)
              .fontSize(17, .medium)
              .allowsHitTesting(false)
            
            let imgPost = data.url.hasSuffix("jpg") || data.url.hasSuffix("png")
            
            if let media = data.secure_media {
              switch media {
              case .first(let data):
                if let url = data.reddit_video?.fallback_url {
                  VideoPlayer(url:  URL(string: url)!, play: $playingVideo, time: $time)
                    .contentMode(.scaleAspectFill)
                    .matchedGeometryEffect(id: "\(url)-video", in: namespaceWrapper.namespace, isSource: true)
                    .frame(height: 600)
                    .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-mask", in: namespaceWrapper.namespace))
                    .id(url)
                    .onTapGesture {
                      withAnimation(.interpolatingSpring(stiffness: 100, damping: 15)) {
                        lightBoxType.url = url
                        lightBoxType.time = time
                      }
                    }
                } else {
                  EmptyView()
                }
              case .second(_):
                EmptyView()
              }
            }
            
            if imgPost {
              let height: CGFloat = 150
              if lightBoxType.url != data.url {
                VStack {
                  WebImage(url: URL(string: data.url))
                    .resizable()
                    .placeholder {
                      RR(12, .gray.opacity(0.35))
                        .frame(maxWidth: contentWidth, minHeight: height, maxHeight: height)
                    }
                    .matchedGeometryEffect(id: "\(data.url)-img", in: namespaceWrapper.namespace)
                    .scaledToFill()
                    .frame(maxWidth: contentWidth, minHeight: height, maxHeight: height)
                    .mask(RR(12, .black).matchedGeometryEffect(id: "\(data.url)-mask", in: namespaceWrapper.namespace))
                    .zIndex(1)
                    .allowsHitTesting(false)
                }
                .contentShape(Rectangle())
                .transition(.offset(x: 0, y: 1))
                //            .id(data.url)
                .simultaneousGesture(
                  lightBoxType.url != nil
                  ? nil
                  : TapGesture().onEnded {
                    //                DispatchQueue.main.async {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
                      //                    disableScroll = true
                      aboveAll = 2
                      lightBoxType.url = data.url
                    }
                  }
                )
              } else {
                Color.clear
                  .frame(width: contentWidth, height: height)
                  .zIndex(1)
              }
            } else if data.selftext != "" {
              Text(data.selftext).lineLimit(3)
                .fontSize(15)
                .opacity(0.75)
                .allowsHitTesting(false)
            }
          }
          .zIndex(1)
          
          HStack(spacing: 0) {
            if let link_flair_text = data.link_flair_text {
              Rectangle()
                .fill(.primary.opacity(0.05))
                .frame(maxWidth: .infinity, maxHeight: 1)
              
              Text(link_flair_text)
                .fontSize(13)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule(style: .continuous).fill(.secondary.opacity(0.2)))
                .foregroundColor(.primary.opacity(0.5))
                .fixedSize()
            }
            Rectangle()
              .fill(.primary.opacity(0.05))
              .frame(maxWidth: .infinity, maxHeight: 1)
          }
          .padding(.horizontal, 2)
          
          HStack {
            VStack(alignment: .leading) {
              NavigationLink {
                UserView(user: User(id: data.author, api: post.redditAPI))
              } label: {
                (Text("by ").font(.system(size: 14, weight: .medium)) + Text(data.author).font(.system(size: 14, weight: .semibold)))
              }
              
              HStack(alignment: .center, spacing: 8) {
                HStack(alignment: .center, spacing: 4) {
                  Image(systemName: "message.fill")
                  Text("\(data.num_comments)")
                }
                HStack(alignment: .center, spacing: 4) {
                  Image(systemName: "hourglass.bottomhalf.filled")
                  let hoursSince = Int((Date().timeIntervalSince1970 - TimeInterval(data.created)) / 3600)
                  Text("\(hoursSince > 23 ? hoursSince / 24 : hoursSince)\(hoursSince > 23 ? "d" : "h")")
                }
              }
              .font(.system(size: 13, weight: .medium))
            }
            //          .fixedSize(horizontal: true, vertical: false)
            .opacity(0.5)
            
            Spacer()
            
            HStack(alignment: .center, spacing: 8) {
              Button {
                Task {
                  var newPost = post
                  _ = await newPost.vote(action: .down)
                  post = newPost
                }
              } label: {
                Image(systemName: "arrow.up")
              }
              .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)
              
              let downup = Int(data.ups - data.downs)
              Text("\(downup > 999 ? downup / 1000 : downup)\(downup > 999 ? "K" : "")")
                .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                .fontSize(16, .semibold)
              
              Button {
                Task {
                  var newPost = post
                  _ = await newPost.vote(action: .down)
                  post = newPost
                }
              } label: {
                Image(systemName: "arrow.down")
              }
              .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
            }
            .fontSize(22, .medium)
          }
        }
        .background(
          GeometryReader { geo in
            Color.clear
              .onAppear {
                contentWidth = geo.size.width
              }
              .onChange(of: geo.size.width) { val in
                contentWidth = val
              }
          }
        )
        .contentShape(Rectangle())
        .swipyActions(leftActionHandler: {
          Task {
            var newPost = post
            _ = await newPost.vote(action: .up)
            post = newPost
          }
        }, rightActionHandler: {
          Task {
            var newPost = post
            _ = await newPost.vote(action: .down)
            post = newPost
          }
        })
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RR(20, .secondary.opacity(0.15)))
        .mask(RR(20, .black))
        .foregroundColor(.primary)
        .multilineTextAlignment(.leading)
        .zIndex(Double(aboveAll))
      } else {
        Text("Oops something went wrong")
      }
    }
    .buttonStyle(PlainButtonStyle())
  }
}

//struct Post_Previews: PreviewProvider {
//    static var previews: some View {
//        Post()
//    }
//}
