//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults
import Markdown

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

class AttributedStringLoader: ObservableObject {
  @Published var data: AttributedString?
  
  func load(str: String) {
    Task.detached(priority: .background) {
//    }
//    Task(priority: .background) {
      let decoder = JSONDecoder()
      let jsonData = (try? decoder.decode(AttributedString.self, from: str.data(using: .utf8)!)) ?? AttributedString()
      await MainActor.run {
        withAnimation {
          self.data = jsonData
        }
      }
    }
  }
}

struct PostLink: View, Equatable {
  static func == (lhs: PostLink, rhs: PostLink) -> Bool {
    return lhs.post == rhs.post && lhs.sub == rhs.sub
  }
  
  var disableOuterVSpacing = false
  @ObservedObject var post: Post
  @ObservedObject var sub: Subreddit
  @StateObject var attrStrLoader = AttributedStringLoader()
  var showSub = false
  var secondary = false
  @EnvironmentObject private var routerProxy: RouterProxy
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  
  //Compact Mode
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactMode) private var compactMode
  @Default(.showVotes) private var showVotes
  @Default(.showSelfText) private var showSelfText
  @Default(.thumbnailPositionRight) private var thumbnailPositionRight
  @Default(.voteButtonPositionRight) private var voteButtonPositionRight
  
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  
  @Default(.showUpvoteRatio) private var showUpvoteRatio
  //  @Default(.fadeReadPosts) private var fadeReadPosts
  
//  @Default(.postLinkTitleSize) private var postLinkTitleSize
//  @Default(.postLinkBodySize) private var postLinkBodySize
  @Default(.showSubsAtTop) private var showSubsAtTop
  @Default(.showTitleAtTop) private var showTitleAtTop
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
    
  var contentWidth: CGFloat {
    let theme = selectedTheme.postLinks.theme
    return UIScreen.screenWidth - ((theme.innerPadding.horizontal + theme.outerHPadding) * 2)
  }
  
  var body: some View {
    let theme = selectedTheme.postLinks
    let fadeReadPosts = theme.theme.unseenType == .fade
    let isCard = theme.theme.type == .card
    let extractedMedia = mediaExtractor(post)
    let layout = compactMode ? AnyLayout(HStackLayout(alignment: .top, spacing: theme.theme.verticalElementsSpacing)) : AnyLayout(VStackLayout(alignment: .leading, spacing: theme.theme.verticalElementsSpacing))
    if let data = post.data {
      let seen = (data.winstonSeen ?? false)
      let over18 = data.over_18 ?? false
      
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        layout {
          
          /// /////////
          /// <UPPER PART>
          /// /////////
          
          if showSubsAtTop && !compactMode {
            SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
              .equatable()
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
              .equatable()
              .frame(maxWidth: compactMode ? compactModeThumbSize : .infinity, maxHeight: compactMode ? compactModeThumbSize : nil, alignment: .leading)
              .clipped()
              .nsfw(over18 && blurPostLinkNSFW)
          }
          
          /// /////////
          /// </UPPER PART>
          /// /////////
          
          
          VStack(alignment: .leading, spacing: compactMode ? theme.theme.verticalElementsSpacing / 2 : theme.theme.verticalElementsSpacing * 1.25) {
            Text(data.title.escape)
              .fontSize(theme.theme.titleText.size, theme.theme.titleText.weight.t)
              .foregroundColor(theme.theme.titleText.color.cs(cs).color())
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if compactMode, let extractedMedia = extractedMedia {
              MediaPresenter(showURLInstead: true, media: extractedMedia, post: post, compact: compactMode, contentWidth: contentWidth)
                .equatable()
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            if data.selftext != "" && showSelfText && !compactMode, let winstonSelftextAttrEncoded = data.winstonSelftextAttrEncoded {
              Text(data.selftext.md()).lineLimit(3)
                .fontSize(theme.theme.bodyText.size, theme.theme.bodyText.weight.t)
                .foregroundColor(theme.theme.bodyText.color.cs(cs).color())
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .onAppear { attrStrLoader.load(str: winstonSelftextAttrEncoded) }
            }
            
            if compactMode {
              if let fullname = data.author_fullname {
                Badge(author: data.author, fullname: fullname, created: data.created, theme: theme.theme.badge, extraInfo: [PresetBadgeExtraInfo().commentsExtraInfo(data:data), PresetBadgeExtraInfo().upvotesExtraInfo(data: data)])
                  .equatable()
              }
            }
          }
          .frame(maxWidth: compactMode ? .infinity : nil, alignment: .topLeading)
          
          if (thumbnailPositionRight && compactMode) || (!compactMode && showTitleAtTop), let extractedMedia = extractedMedia {
            MediaPresenter(media: extractedMedia, post: post, compact: compactMode, contentWidth: contentWidth)
              .equatable()
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
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
            .equatable()
        }
        
        if !compactMode {
          HStack {
            if let fullname = data.author_fullname {
              Badge(saved: data.saved, author: data.author, fullname: fullname, created: data.created, theme: theme.theme.badge, extraInfo: !showVotes ? [PresetBadgeExtraInfo().commentsExtraInfo(data: data), PresetBadgeExtraInfo().upvotesExtraInfo(data: data)] : [PresetBadgeExtraInfo().commentsExtraInfo(data: data)])
                .equatable()
            }
            
            Spacer()
            
            HStack(alignment: .center) {
              showVotes ? VotesCluster(data: data, likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post) : nil
            }
            .fontSize(22, .medium)
          }
        }
        
      }
      .padding(.horizontal, theme.theme.innerPadding.horizontal)
      .padding(.vertical, theme.theme.innerPadding.vertical)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        ZStack {
          if !secondary && !isCard {
            theme.theme.bg.color.cs(cs).color()
            theme.theme.stickyPostBorderColor.color.cs(cs).color()
          } else {
            if theme.theme.bg.blurry {
              RR(theme.theme.cornerRadius, .ultraThinMaterial)
            }
            RR(theme.theme.cornerRadius, secondary ? Color("primaryInverted").opacity(0.15) : theme.theme.bg.color.cs(cs).color())
            if (data.stickied ?? false) {
              RoundedRectangle(cornerRadius: theme.theme.cornerRadius, style: .continuous)
                .stroke(theme.theme.stickyPostBorderColor.color.cs(cs).color(), lineWidth: theme.theme.stickyPostBorderColor.thickness)
            }
          }
        }
          .allowsHitTesting(false)
      )
      .mask(RR(theme.theme.cornerRadius, Color.black))
      .overlay(
        ZStack {
          switch theme.theme.unseenType {
          case .dot(let color):
            ZStack {
              Circle()
                .fill(Color.hex("CFFFDE"))
                .frame(width: 5, height: 5)
              Circle()
                .fill(color.cs(cs).color())
                .frame(width: 8, height: 8)
                .blur(radius: 8)
            }
          case .fade:
            EmptyView()
          }
        }
          .padding(.all, 11)
          .scaleEffect(seen ? 0.1 : 1)
          .opacity(seen ? 0 : 1)
          .allowsHitTesting(false)
        , alignment: .topTrailing
      )
      .scaleEffect(1)
      .contentShape(Rectangle())
      .swipyUI(
        onTap: {
          routerProxy.router.path.append(PostViewPayload(post: post, postSelfAttr: attrStrLoader.data, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
        },
        actionsSet: postSwipeActions,
        entity: post
      )
      .padding(.horizontal, !secondary && isCard ? theme.theme.outerHPadding : 0 )
      .padding(.vertical, !disableOuterVSpacing && !secondary && isCard ? (theme.spacing / 2) : 0)
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
        
      }, preview: { NavigationStack { PostView(post: post, subreddit: sub, forceCollapse: true).equatable() }.environmentObject(post.redditAPI).environmentObject(routerProxy) })
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
        .mask(RR(12, Color.black))
        .contentShape(Rectangle())
        .frame(width: scaledCompactModeThumbSize(), height: scaledCompactModeThumbSize())
    }
  }
}


struct SubsNStuffLine: View, Equatable {
  static func == (lhs: SubsNStuffLine, rhs: SubsNStuffLine) -> Bool {
    lhs.post.id == rhs.post.id
  }
  
  var showSub: Bool
  var feedsAndSuch: [String]
  var post: Post
  var sub: Subreddit
  var routerProxy: RouterProxy
  var over18: Bool
  
  var body: some View {
    HStack(spacing: 0) {
      
      if showSub || feedsAndSuch.contains(sub.id) {
        FlairTag(text: "r/\(sub.data?.display_name ?? post.data?.subreddit ?? "Error")", color: .blue)
          .highPriorityGesture(TapGesture() .onEnded {
            routerProxy.router.path.append(SubViewType.posts(Subreddit(id: post.data?.subreddit ?? "", api: post.redditAPI)))
          })
        
        WDivider()
      }
      
      if over18 {
        FlairTag(text: "NSFW", color: .red)
        WDivider()
      }
      
      if let link_flair_text = post.data?.link_flair_text {
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
