//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults
import Markdown



let POSTLINK_INNER_H_PAD: CGFloat = 16

struct PostLinkView: View, Equatable {
  static func == (lhs: PostLinkView, rhs: PostLinkView) -> Bool {
    lhs.size == rhs.size && lhs.seen == rhs.seen && lhs.stickied == rhs.stickied && lhs.post == rhs.post && lhs.contentWidth == rhs.contentWidth && lhs.selectedTheme == rhs.selectedTheme
  }
  
  var size: CGSize
  var stickied: Bool
  var seen = false
  var disableOuterVSpacing = false
  var post: Post
  var sub: Subreddit
  var showSub = false
  var secondary = false
  var routerProxy: RouterProxy
  var contentWidth: CGFloat
  
  var blurPostLinkNSFW: Bool
  
  var postSwipeActions: SwipeActionsSet
  var compactMode: Bool
  var showVotes: Bool
  var showSelfText: Bool
  var thumbnailPositionRight: Bool
  var voteButtonPositionRight: Bool
  
  var readPostOnScroll: Bool
  var hideReadPosts: Bool
  
  var showUpvoteRatio: Bool
  
  var showSubsAtTop: Bool
  var showTitleAtTop: Bool
  
  var selectedTheme: WinstonTheme
  var cs: ColorScheme
  
  nonisolated func openPost() {
    routerProxy.router.path.append(PostViewPayload(post: post, postSelfAttr: nil, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
  }
  
  var body: some View {
    if let data = post.data {
      let theme = selectedTheme.postLinks
      let fadeReadPosts = theme.theme.unseenType == .fade
      
      let over18 = data.over_18 ?? false
      
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        if compactMode {
          PostLinkCompact(post: post, theme: theme, sub: sub, showSub: showSub, routerProxy: routerProxy, contentWidth: contentWidth, blurPostLinkNSFW: blurPostLinkNSFW, showVotes: showVotes, thumbnailPositionRight: thumbnailPositionRight, voteButtonPositionRight: voteButtonPositionRight, showUpvoteRatio: showUpvoteRatio, showSubsAtTop: showSubsAtTop, over18: over18, cs: cs)
            .id(post.id)
        } else {
          PostLinkNormal(post: post, theme: theme, sub: sub, showSub: showSub, routerProxy: routerProxy, contentWidth: contentWidth, blurPostLinkNSFW: blurPostLinkNSFW, showVotes: showVotes, showUpvoteRatio: showUpvoteRatio, showSubsAtTop: showSubsAtTop, showSelfText: showSelfText, showTitleAtTop: showTitleAtTop, over18: over18, cs: cs)
            .id(post.id)
        }
      }
      .padding(.horizontal, theme.theme.innerPadding.horizontal)
      .padding(.vertical, theme.theme.innerPadding.vertical)
      .frame(width: size.width, height: size.height, alignment: .top)
      .fixedSize()
      .background(PostLinkBG(theme: theme, stickied: data.stickied, secondary: secondary, cs: cs))
      .mask(RR(theme.theme.cornerRadius, Color.black))
      .overlay(PostLinkGlowDot(unseenType: theme.theme.unseenType, seen: seen, cs: cs), alignment: .topTrailing)
      .scaleEffect(1)
      .compositingGroup()
      .contentShape(Rectangle())
      .swipyUI(onTap: openPost, actionsSet: postSwipeActions, entity: post)
      .opacity(fadeReadPosts && seen ? 0.6 : 1)
      .contextMenu(menuItems: { PostLinkContext(post: post) }, preview: { PostLinkContextPreview(post: post, sub: sub, routerProxy: routerProxy).id("\(post.id)-preview-navigation-stack") })
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
//      .background(GeometryReader { geo in Color.clear.onAppear { print(data.title, "post", post.winstonData?.postDimensions?.size, geo.size) } })
    } else {
      Text("Oops something went wrong")
    }
  }
}

struct PostLinkGlowDot: View {
  let unseenType: UnseenType
  let seen: Bool
  let cs: ColorScheme
  var body: some View {
    ZStack {
      switch unseenType {
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
  }
}

struct PostLinkBG: View {
  let theme: SubPostsListTheme
  let stickied: Bool?
  let secondary: Bool
  let cs: ColorScheme
  var body: some View {
    ZStack {
      if !secondary && theme.theme.outerHPadding == 0 {
        theme.theme.bg.color.cs(cs).color()
        if stickied ?? false {
          theme.theme.stickyPostBorderColor.color.cs(cs).color()
        }
      } else {
        if theme.theme.bg.blurry {
          RR(theme.theme.cornerRadius, .ultraThinMaterial)
        }
        RR(theme.theme.cornerRadius, secondary ? Color("primaryInverted").opacity(0.15) : theme.theme.bg.color.cs(cs).color())
        if (stickied ?? false) {
          RoundedRectangle(cornerRadius: theme.theme.cornerRadius, style: .continuous)
            .stroke(theme.theme.stickyPostBorderColor.color.cs(cs).color(), lineWidth: theme.theme.stickyPostBorderColor.thickness)
        }
      }
    }
    .allowsHitTesting(false)
  }
}

struct PostLink: View, Equatable {
  static func == (lhs: PostLink, rhs: PostLink) -> Bool {
    return lhs.post.data == rhs.post.data && lhs.sub.data == rhs.sub.data
  }
  
  var disableOuterVSpacing = false
  @ObservedObject var post: Post
  var sub: Subreddit
  var showSub = false
  var secondary = false
  @EnvironmentObject private var routerProxy: RouterProxy
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactMode) private var compactMode
  @Default(.showVotes) private var showVotes
  @Default(.showSelfText) private var showSelfText
  @Default(.thumbnailPositionRight) private var thumbnailPositionRight
  @Default(.voteButtonPositionRight) private var voteButtonPositionRight
  
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  
  @Default(.showUpvoteRatio) private var showUpvoteRatio
  
  @Default(.showSubsAtTop) private var showSubsAtTop
  @Default(.showTitleAtTop) private var showTitleAtTop
  
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    let seen = (post.data?.winstonSeen ?? false)
    let stickied = (post.data?.stickied ?? false)
      PostLinkView(
        size: CGSize(width: post.winstonData?.postDimensions?.size.width ?? 0, height: post.winstonData?.postDimensions?.size.height ?? 0),
        stickied: stickied,
        seen: seen,
        disableOuterVSpacing: disableOuterVSpacing,
        post: post,
        sub: sub,
        showSub: showSub,
        secondary: secondary,
        routerProxy: routerProxy,
        contentWidth: getPostDimensions(post: post, secondary: secondary, theme: selectedTheme)?.titleSize.width ?? 0,
        blurPostLinkNSFW: blurPostLinkNSFW,
        postSwipeActions: postSwipeActions,
        compactMode: compactMode,
        showVotes: showVotes,
        showSelfText: showSelfText,
        thumbnailPositionRight: thumbnailPositionRight,
        voteButtonPositionRight: voteButtonPositionRight,
        readPostOnScroll: readPostOnScroll,
        hideReadPosts: hideReadPosts,
        showUpvoteRatio: showUpvoteRatio,
        showSubsAtTop: showSubsAtTop,
        showTitleAtTop: showTitleAtTop,
        selectedTheme: selectedTheme,
        cs: cs
      )
      .onChange(of: selectedTheme) { x in
        post.winstonData?.postDimensions = getPostDimensions(post: post, theme: x)
      }
//      .equatable()
  }
}



