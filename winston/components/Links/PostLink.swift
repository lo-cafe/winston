//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults

struct FlairTag: View {
  var text: String
  var color: Color = .secondary
  var body: some View {
    Text(text)
      .fontSize(13)
      .padding(.horizontal, 9)
      .padding(.vertical, 2)
      .background(Capsule(style: .continuous).fill(color.opacity(0.2)))
      .foregroundColor(.primary.opacity(0.5))
      .frame(maxWidth: 150, alignment: .leading)
      .fixedSize(horizontal: true, vertical: false)
      .lineLimit(1)
  }
}

let POSTLINK_INNER_H_PAD: CGFloat = 16

private class Appeared: ObservableObject {
  @Published var isIt: Bool = false
}

struct PostLink: View, Equatable {
  static func == (lhs: PostLink, rhs: PostLink) -> Bool {
    lhs.post == rhs.post && lhs.sub == rhs.sub
  }
  
  @EnvironmentObject private var router: Router
  @ObservedObject var post: Post
  @ObservedObject var sub: Subreddit
  var showSub = false
  @Default(.preferenceShowPostsCards) private var preferenceShowPostsCards
  @Default(.preferenceShowPostsAvatars) private var preferenceShowPostsAvatars
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  @State private var postSwipeActions: SwipeActionsSet = Defaults[.postSwipeActions]
  @Default(.compactMode) var compactMode
  
  @Default(.postLinksInnerHPadding) private var postLinksInnerHPadding
  @Default(.postLinksInnerVPadding) private var postLinksInnerVPadding
  
  @Default(.cardedPostLinksOuterHPadding) private var cardedPostLinksOuterHPadding
  @Default(.cardedPostLinksOuterVPadding) private var cardedPostLinksOuterVPadding
  @Default(.cardedPostLinksInnerHPadding) private var cardedPostLinksInnerHPadding
  @Default(.cardedPostLinksInnerVPadding) private var cardedPostLinksInnerVPadding
  
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  
  @Default(.showUpvoteRatio) var showUpvoteRatio
  @Default(.fadeReadPosts) var fadeReadPosts
  @StateObject private var appeared = Appeared()
  
  var contentWidth: CGFloat { UIScreen.screenWidth - ((preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding) * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0) }
  
  var body: some View {
    let layout = compactMode ? AnyLayout(HStackLayout(alignment: .top, spacing: 12)) : AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
    if let data = post.data {
      let seen = (data.winstonSeen ?? false)
      let isLinkPost = !data.url.isEmpty && !data.is_self && !(data.is_video ?? false) && !(data.is_gallery ?? false) && data.post_hint != "image"
      let over18 = data.over_18 ?? false
      VStack(alignment: .leading, spacing: 8) {
        layout {
          VStack(alignment: .leading, spacing: compactMode ? 4 : 10) {
            Text(data.title.escape)
              .lineLimit(compactMode ? 2 : nil)
              .fontSize(compactMode ? 16 : 17, .medium)
              .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if data.selftext != "" {
              Text(data.selftext.md()).lineLimit(compactMode ? 2 : 3)
                .fontSize(14)
                .opacity(0.75)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            if compactMode {
              if let fullname = data.author_fullname {
                Badge(showAvatar: preferenceShowPostsAvatars, author: data.author, fullname: fullname, created: data.created, extraInfo: ["message.fill":"\(data.num_comments)", (data.ups >= 0 ? "arrow.up" : "arrow.down"): "\(formatBigNumber(data.ups))"])
              }
            }
          }
          .frame(maxWidth: compactMode ? .infinity : nil, alignment: .topLeading)
          
          let imgPost = data.is_gallery == true || data.url.hasSuffix("jpg") || data.url.hasSuffix("png") || data.url.hasSuffix("webp") || data.url.contains("imgur.com")
          
          if imgPost {
            ImageMediaPost(compact: compactMode, post: post, contentWidth: contentWidth)
          }
          
          if !compactMode {
            Group {
              if let media = data.secure_media {
                switch media {
                case .first(let datas):
                  let vid = datas.reddit_video
                  if let url = vid.hls_url, let width = vid.width, let height = vid.height, let rootURL = rootURL(url) {
                    VideoPlayerPost(sharedVideo: SharedVideo(url: rootURL, size: CGSize(width: width, height: height)))
                      .scaledToFill()
                  }
                case .second(_):
                  EmptyView()
                }
              }
              
              if let redditVidPreview = data.preview?.reddit_video_preview, let status = redditVidPreview.transcoding_status, status == "completed", let url = redditVidPreview.hls_url, let rootURL = rootURL(url), let width = redditVidPreview.width, let height = redditVidPreview.height {
                VideoPlayerPost(sharedVideo: SharedVideo(url: rootURL, size: CGSize(width: width, height: height)))
                  .scaledToFill()
              } else if !imgPost {
                if isLinkPost {
                  PreviewLink(data.url, compact: compactMode, contentWidth: contentWidth, media: data.secure_media)
                }
              }
            }
            .frame(maxWidth: compactMode ? compactModeThumbSize : .infinity, maxHeight: compactMode ? compactModeThumbSize : nil, alignment: .leading)
            .clipped()
            .nsfw(over18 && blurPostLinkNSFW)
          }
          
          if compactMode {
            VStack(alignment: .center, spacing: 2) {
                          
              VoteButton(color: data.likes != nil && data.likes! ? .orange : .gray, voteAction: .up, image: "arrow.up", post: post)
              
              Spacer()
              
              VoteButton(color: data.likes != nil && !data.likes! ? .blue : .gray, voteAction: .down, image: "arrow.down", post: post)
              
              Spacer()
              
            }
            .frame(maxHeight: .infinity)
            .fontSize(22, .medium)
          }
          
        }
        .zIndex(1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
        HStack(spacing: 0) {
          
          if showSub || feedsAndSuch.contains(sub.id) {
            FlairTag(text: "r/\(sub.data?.display_name ?? post.data?.subreddit ?? "Error")", color: .blue)
              .highPriorityGesture(TapGesture() .onEnded {
                router.path.append(SubViewType.posts(Subreddit(id: post.data?.subreddit ?? "", api: post.redditAPI)))
              })
            
            WDivider()
          }
          
          if over18 {
            FlairTag(text: "NSFW", color: .red)
            WDivider()
          }
          
          if let link_flair_text = data.link_flair_text {
            FlairTag(text: link_flair_text.emojied())
              .allowsHitTesting(false)
          }
          
          if !showSub && !feedsAndSuch.contains(sub.id) {
            WDivider()
          }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
        
        
          
        if !compactMode {
          HStack {
            if let fullname = data.author_fullname {
              Badge(showAvatar: preferenceShowPostsAvatars, author: data.author, fullname: fullname, created: data.created, extraInfo: ["message.fill":"\(data.num_comments)"])
            }
            
            Spacer()
            
            HStack(alignment: .center) {
              VotesCluster(data: data, likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post)
            }
            .fontSize(22, .medium)
          }
        }
      }
      .padding(.horizontal, preferenceShowPostsCards ? cardedPostLinksInnerHPadding : postLinksInnerHPadding)
      .padding(.vertical, preferenceShowPostsCards ? cardedPostLinksInnerVPadding : postLinksInnerVPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        !preferenceShowPostsCards
        ? nil
        : RR(20, .listBG)
          .allowsHitTesting(false)
      )
      .mask(RR(preferenceShowPostsCards ? 20 : 0, .black))
      .overlay(
        fadeReadPosts
        ? nil
        : ZStack {
          Circle()
            .fill(Color.hex("CFFFDE"))
            .frame(width: 5, height: 5)
          Circle()
            .fill(Color.hex("4FFF85"))
            .frame(width: 8, height: 8)
            .blur(radius: 8)
        }
          .padding(.all, 11)
          .scaleEffect(seen ? 0.1 : 1)
          .opacity(seen ? 0 : 1)
          .allowsHitTesting(false)
        , alignment: .topTrailing
      )
      .padding(.horizontal, preferenceShowPostsCards ? cardedPostLinksOuterHPadding : 0 )
      .padding(.vertical, preferenceShowPostsCards ? cardedPostLinksOuterVPadding : 0)
      .compositingGroup()
      .opacity(fadeReadPosts && seen ? 0.6 : 1)
      .contentShape(Rectangle())
      .swipyUI(
        onTap: {
          router.path.append(PostViewPayload(post: post, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
        },
        actionsSet: postSwipeActions,
        entity: post
      )
      .contextMenu(menuItems: {
        VStack {
          if let perma = URL(string: "https://reddit.com\(data.permalink.escape.urlEncoded)") {
            ShareLink(item: perma) { Label("Share", systemImage: "square.and.arrow.up") }
          }
          Button { router.path.append(PostViewPayload(post: post, sub: feedsAndSuch.contains(sub.id) ? sub : sub)) } label: { Label("Open post", systemImage: "rectangle.and.hand.point.up.left.filled") }
          Button {  withAnimation {
            post.toggleSeen(optimistic: true)
          } } label: { Label("Toggle seen", systemImage: "eye") }
        }
      }, preview: { NavigationStack { PostView(post: post, subreddit: sub, forceCollapse: true) }.environmentObject(post.redditAPI) })
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
      .zIndex(1)
      .onDisappear {
        Task(priority: .background) {
          if readPostOnScroll {
            post.toggleSeen(true, optimistic: true)
          }
          if hideReadPosts {
            await post.hide(true)
          }
        }
      }
      .onAppear {
        let newPostSwipeActions = Defaults[.postSwipeActions]
        if postSwipeActions != newPostSwipeActions {
          postSwipeActions = newPostSwipeActions
        }
      }
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

struct CustomLabel: LabelStyle {
  var spacing: Double = 0.0
  
  func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: spacing) {
      configuration.icon
      configuration.title
    }
  }
}
