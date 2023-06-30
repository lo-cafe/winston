//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import CachedAsyncImage
import Defaults
import MarkdownUI
import VideoPlayer
import CoreMedia

struct PostView: View {
  var post: Post
  var subreddit: SubredditData
  @State var loading = true
  @State var loadingMore = false
  @State var sort: CommentSortOption = Defaults[.preferredCommentSort]
  @State var comments: [Comment]?
  @State var lastPostAfter: String?
  @EnvironmentObject var redditAPI: RedditAPI
  @EnvironmentObject var namespaceWrapper: NamespaceWrapper
  @EnvironmentObject var lightBoxType: ContentLightBox
  @State var playingVideo = true
  @State private var time: CMTime = .zero
  @State var contentWidth: CGFloat = .zero

  
  func asyncFetch(loadMore: Bool = false) async {
      if let result = await post.fetchComments(sort: sort, after: nil), let newComments = result.0 {
      withAnimation {
        if loadMore {
          comments = (comments ?? []) + newComments
        } else {
          comments = newComments
        }
        loading = false
      }
      lastPostAfter = result.1
      loadingMore = false
    }
  }
  
  func fetch(loadMore: Bool = false) {
    if loadMore {
      loadingMore = true
    }
    Task {
      await asyncFetch(loadMore: loadMore)
    }
  }
  
    var body: some View {
      ScrollView {
        if let data = post.data {
          VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
              Text(data.title)
                .fontSize(20, .semibold)
              
              let imgPost = data.url.hasSuffix("jpg") || data.url.hasSuffix("png")
              
              if let media = data.secure_media {
                switch media {
                case .first(let data):
                  if let url = data.reddit_video?.fallback_url {
                    VideoPlayer(url:  URL(string: url)!, play: $playingVideo, time: $time)
                      .contentMode(.scaleAspectFill)
                      .matchedGeometryEffect(id: "\(url)-avideo", in: namespaceWrapper.namespace, isSource: true)
                      .frame(height: 600)
                      .mask(RR(12, .black).matchedGeometryEffect(id: "\(url)-amask", in: namespaceWrapper.namespace))
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
                    CachedAsyncImage(url: URL(string: data.url)) { image in
                      image
                      //                Image("cat")
                        .resizable()
                        .scaledToFill()
                        .matchedGeometryEffect(id: "\(data.url)-aimg", in: namespaceWrapper.namespace)
                        .frame(maxWidth: contentWidth, minHeight: height, maxHeight: height)
                        .mask(RR(12, .black).matchedGeometryEffect(id: "\(data.url)-amask", in: namespaceWrapper.namespace))
                        .zIndex(1)
                      //              .onAppear {
                      //                aboveAll = 0
                      //              }
                    } placeholder: {
                      RR(12, .gray.opacity(0.5))
                        .frame(maxWidth: contentWidth, minHeight: height, maxHeight: height)
                    }
                    .allowsHitTesting(false)
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
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
                        //                      aboveAll = 2
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
              
              if data.selftext != "" {
                Markdown(data.selftext)
                  .markdownTextStyle {
                    FontSize(15)
                  }
              }
              
              HStack {
                Avatar(userID: data.author)
                
                VStack(alignment: .leading) {
                  (Text("by ").font(.system(size: 14, weight: .medium)).foregroundColor(.primary.opacity(0.5)) + Text(data.author).font(.system(size: 14, weight: .semibold)).foregroundColor(.blue))
                  
                  HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "hourglass.bottomhalf.filled")
                    let hoursSince = Int((Date().timeIntervalSince1970 - TimeInterval(data.created)) / 3600)
                    Text("\(hoursSince > 23 ? hoursSince / 24 : hoursSince)\(hoursSince > 23 ? "d" : "h")")
                  }
                  .font(.system(size: 12, weight: .medium))
                  .opacity(0.5)
                }
                
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
            //          .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            //          .background(RR(20, .secondary.opacity(0.15)))
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .onAppear {
              if comments == nil {
                fetch()
              }
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
            
            LazyVStack(alignment: .leading, spacing: 8) {
              Text("Comments")
                .fontSize(20, .bold)
              if loading {
                ProgressView()
                  .progressViewStyle(.circular)
                  .frame(maxWidth: .infinity, minHeight: 300 )
              } else {
                if let comments = comments {
                  ForEach(comments) { comment in
                    if let data = comment.data {
                      CommentLink(data: data)
                    }
                  }
                }
              }
            }
          }
          .padding(.vertical, 16)
          .padding(.horizontal, 8)
          .frame(maxWidth: .infinity, alignment: .leading)
        } else {
          VStack {}
        }
      }
      .overlay(
        HStack(spacing: 16) {
          if let data = post.data {
            Button { } label: {
              Image(systemName: "bookmark.fill")
            }
            
            Button { } label: {
              Image(systemName: "square.and.arrow.up.fill")
            }
            
            Button { } label: {
              Image(systemName: "arrowshape.turn.up.left.fill")
            }
            
            HStack(alignment: .center, spacing: 6) {
              Button { } label: {
                Image(systemName: "arrow.up")
              }
              .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)
              
              
              let downup = Int(data.ups - data.downs)
              Text("\(downup > 999 ? downup / 1000 : downup)\(downup > 999 ? "K" : "")")
                .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                .fontSize(16, .semibold)
              
              Button { } label: {
                Image(systemName: "arrow.down")
              }
              .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
            }
          }
        }
        .fontSize(24, .semibold)
        .foregroundColor(.blue)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Capsule(style: .continuous).fill(.ultraThinMaterial))
        .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.05), lineWidth: 1).padding(.all, 0.5))
        .padding(.all, 8)
        , alignment: .bottomTrailing
      )
      .navigationBarTitle(Text("\(post.data?.num_comments ?? 0) comments"), displayMode: .inline)
      .navigationBarItems(
        trailing:
          HStack {
            Menu {
              ForEach(CommentSortOption.allCases) { opt in
                Button {
                  sort = opt
                } label: {
                  HStack {
                    Text(opt.rawVal.value.capitalized)
                    Spacer()
                    Image(systemName: opt.rawVal.icon)
                      .foregroundColor(.blue)
                      .fontSize(17, .bold)
                  }
                }
              }
            } label: {
              Button { } label: {
                Image(systemName: sort.rawVal.icon)
                  .foregroundColor(.blue)
                  .fontSize(17, .bold)
              }
            }
            
            Button { } label: {
              let communityIcon = subreddit.community_icon.split(separator: "?")
              let icon = subreddit.icon_img == "" ? communityIcon.count > 0 ? String(communityIcon[0]) : "" : subreddit.icon_img
              CachedAsyncImage(url: URL(string: icon)) { image in
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 30, height: 30)
                  .mask(Circle())
              } placeholder: {
                Text(subreddit.display_name.prefix(1).uppercased())
                  .frame(width: 30, height: 30)
                  .background(.blue, in: Circle())
                  .mask(Circle())
                  .fontWeight(.semibold)
              }
            }
          }
          .animation(nil, value: sort)
      )
      
    }
}

//struct Post_Previews: PreviewProvider {
//    static var previews: some View {
//        PostLink()
//    }
//}
