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

struct PostLinkNoSub: View, Equatable {
  static func == (lhs: PostLinkNoSub, rhs: PostLinkNoSub) -> Bool {
    lhs.post == rhs.post
  }
  var showSub = false
  var post: Post
  var secondary = false
  var body: some View {
    PostLinkSubContainer(showSub: showSub, post: post, sub: Subreddit(id: post.data?.subreddit ?? "Error", api: post.redditAPI), secondary: secondary)
      .equatable()
  }
}

struct PostLinkSubContainer: View, Equatable {
  static func == (lhs: PostLinkSubContainer, rhs: PostLinkSubContainer) -> Bool {
    lhs.post == rhs.post
  }
  var showSub = false
  var post: Post
  @StateObject var sub: Subreddit
  var secondary = false
  
  var body: some View {
    PostLink(post: post, sub: sub, showSub: showSub, secondary: secondary)
      .equatable()
  }
}

struct PostLink: View, Equatable {
  static func == (lhs: PostLink, rhs: PostLink) -> Bool {
    lhs.post == rhs.post && lhs.sub == rhs.sub
  }
  
  @ObservedObject var post: Post
  @ObservedObject var sub: Subreddit
  var showSub = false
  var secondary = false
  @EnvironmentObject private var router: Router
  @Default(.preferenceShowPostsCards) private var preferenceShowPostsCards
  @Default(.preferenceShowPostsAvatars) private var preferenceShowPostsAvatars
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  @State private var postSwipeActions: SwipeActionsSet = Defaults[.postSwipeActions]
  
  //Compact Mode
  @Default(.compactMode) var compactMode
  @Default(.showVotes) var showVotes
  @Default(.showSelfText) var showSelfText
  @Default(.thumbnailPositionRight) var thumbnailPositionRight
  @Default(.voteButtonPositionRight) var voteButtonPositionRight
  
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
  
  @Default(.postLinkTitleSize) var postLinkTitleSize
  @Default(.postLinkBodySize) var postLinkBodySize
  @Default(.showSubsAtTop) var showSubsAtTop
  @Default(.showTitleAtTop) var showTitleAtTop
  
  @StateObject private var appeared = Appeared()
  
  var contentWidth: CGFloat { UIScreen.screenWidth - ((preferenceShowPostsCards ? cardedPostLinksOuterHPadding : postLinksInnerHPadding) * 2) - (preferenceShowPostsCards ? (preferenceShowPostsCards ? cardedPostLinksInnerHPadding : 0) * 2 : 0)  }
  
  var body: some View {
    let extractedMedia = mediaExtractor(post)
    let layout = compactMode ? AnyLayout(HStackLayout(alignment: .top, spacing: 12)) : AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
    if let data = post.data {
      let seen = (data.winstonSeen ?? false)
      let over18 = data.over_18 ?? false
      
      VStack(alignment: .leading, spacing: 8) {
        layout {
          
          /// /////////
          /// <UPPER PART>
          /// /////////
          
          if showSubsAtTop && !compactMode {
            SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, router: router, over18: over18, data: data)
          }
          
          if compactMode && showVotes && !voteButtonPositionRight {
            VStack(alignment: .center, spacing: 2) {
              
              VoteButton(color: data.likes != nil && data.likes! ? .orange : .gray, voteAction: .up, image: "arrow.up", post: post)
              
              Spacer()
              
              VoteButton(color: data.likes != nil && !data.likes! ? .blue : .gray, voteAction: .down, image: "arrow.down", post: post)
              
              Spacer()
              
            }
            .frame(maxHeight: .infinity)
            .fontSize(22, .medium)
          }
          

          if (!thumbnailPositionRight && compactMode) || (!compactMode && !showTitleAtTop), let extractedMedia = extractedMedia {
            MediaPresenter(media: extractedMedia, post: post, compact: compactMode, contentWidth: contentWidth)
            .frame(maxWidth: compactMode ? compactModeThumbSize : .infinity, maxHeight: compactMode ? compactModeThumbSize : nil, alignment: .leading)
            .clipped()
            .nsfw(over18 && blurPostLinkNSFW)
          }
          
          /// /////////
          /// </UPPER PART>
          /// /////////
      
          
          VStack(alignment: .leading, spacing: compactMode ? 4 : 10) {
            Text(data.title.escape)
              .fontSize(postLinkTitleSize, .medium)
              .frame(maxWidth: .infinity, alignment: .topLeading)
            
            
            if compactMode, let extractedMedia = extractedMedia {
              MediaPresenter(showURLInstead: true, media: extractedMedia, post: post, compact: compactMode, contentWidth: contentWidth)
              .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            if data.selftext != "" && showSelfText && !compactMode {
              Text(data.selftext.md()).lineLimit(3)
                .fontSize(postLinkBodySize)
                .opacity(0.75)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            if compactMode {
              if let fullname = data.author_fullname {
                Badge(showAvatar: preferenceShowPostsAvatars, author: data.author, fullname: fullname, created: data.created, extraInfo: [PresetBadgeExtraInfo().commentsExtraInfo(data:data), PresetBadgeExtraInfo().upvotesExtraInfo(data: data)])
              }
            }
          }
          .frame(maxWidth: compactMode ? .infinity : nil, alignment: .topLeading)
                    
          if (thumbnailPositionRight && compactMode) || (!compactMode && showTitleAtTop), let extractedMedia = extractedMedia {
            MediaPresenter(media: extractedMedia, post: post, compact: compactMode, contentWidth: contentWidth)
            .frame(maxWidth: compactMode ? compactModeThumbSize : .infinity, maxHeight: compactMode ? compactModeThumbSize : nil, alignment: .leading)
            .clipped()
            .nsfw(over18 && blurPostLinkNSFW)
          }
          
          if compactMode && showVotes && voteButtonPositionRight {
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
        
        if !showSubsAtTop || compactMode {
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, router: router, over18: over18, data: data)
        }

        if !compactMode {
          HStack {
            if let fullname = data.author_fullname {
              Badge(saved: data.saved, showAvatar: preferenceShowPostsAvatars, author: data.author, fullname: fullname, created: data.created, extraInfo: !showVotes ? [PresetBadgeExtraInfo().commentsExtraInfo(data: data), PresetBadgeExtraInfo().upvotesExtraInfo(data: data)] : [PresetBadgeExtraInfo().commentsExtraInfo(data: data)])
            }
            
            Spacer()
            
            HStack(alignment: .center) {
              showVotes ? VotesCluster(data: data, likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post) : nil
            }
            .fontSize(22, .medium)
          }
        }
        
      }
      .padding(.horizontal, preferenceShowPostsCards ? cardedPostLinksInnerHPadding : postLinksInnerHPadding)
      .padding(.vertical, preferenceShowPostsCards ? cardedPostLinksInnerVPadding : postLinksInnerVPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        ZStack {
          if !secondary && !preferenceShowPostsCards {
            Color.green.opacity((data.stickied ?? false) ? 0.1 : 0)
          } else {
            RR(20, secondary ? Color("primaryInverted").opacity(0.15) : .listBG)
            if (data.stickied ?? false) {
              RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.green.opacity(0.3), lineWidth: 4)
            }
          }
        }
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
      .contentShape(Rectangle())
      .swipyUI(
        onTap: {
          router.path.append(PostViewPayload(post: post, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
        },
        actionsSet: postSwipeActions,
        entity: post
      )
      .padding(.horizontal, !secondary && preferenceShowPostsCards ? cardedPostLinksOuterHPadding : 0 )
      .padding(.vertical, !secondary && preferenceShowPostsCards ? cardedPostLinksOuterVPadding : 0)
      .compositingGroup()
      .opacity(fadeReadPosts && seen ? 0.6 : 1)
      .contextMenu(menuItems: {
        
        if let perma = URL(string: "https://reddit.com\(data.permalink.escape.urlEncoded)") {
          ShareLink(item: perma) { Label("Share", systemImage: "square.and.arrow.up") }
        }
        
        ForEach(allPostSwipeActions) { action in
          let active = action.active(post)
          if action.enabled(post) {
            Button {
              Task(priority: .background) {
                await action.action(post)
              }
            } label: {
              Label(active ? "Undo \(action.label.lowercased())" : action.label, systemImage: active ? action.icon.active : action.icon.normal)
                .foregroundColor(action.bgColor.normal == "353439" ? action.color.normal == "FFFFFF" ? Color.blue : Color.hex(action.color.normal) : Color.hex(action.bgColor.normal))
            }
          }
        }
        
        if let perma = URL(string: "https://reddit.com\(data.permalink.escape.urlEncoded)") {
          ShareLink(item: perma) { Label("Share", systemImage: "square.and.arrow.up") }
        }
        
      }, preview: { NavigationStack { PostView(post: post, subreddit: sub, forceCollapse: true) }.environmentObject(post.redditAPI).environmentObject(router) })
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
      .zIndex(1)
      .onDisappear {
        Task(priority: .background) {
          if readPostOnScroll {
            await post.toggleSeen(true, optimistic: true)
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

struct EmptyThumbnail: View {
  @Default(.showSelfPostThumbnails) var showSelfPostThumbnails
  var body: some View {
    if showSelfPostThumbnails {
      Image("emptyThumb")
        .resizable()
        .scaledToFill()
        .clipped()
        .mask(RR(12, .black))
        .contentShape(Rectangle())
        .frame(width: scaledCompactModeThumbSize(), height: scaledCompactModeThumbSize())
    }
  }
}


struct SubsNStuffLine: View {
  var showSub: Bool
  var feedsAndSuch: [String]
  var post: Post
  var sub: Subreddit
  var router: Router
  var over18: Bool
  var data: PostData
  
  var body: some View {
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
  }
}
