//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults
import Markdown
import NukeUI



let POSTLINK_INNER_H_PAD: CGFloat = 16

struct PostLink: View, Equatable, Identifiable {
  static func == (lhs: PostLink, rhs: PostLink) -> Bool {
    return lhs.id == rhs.id && lhs.avatarRequest?.url == rhs.avatarRequest?.url && lhs.cachedVideo == rhs.cachedVideo && lhs.repostAvatarRequest?.url == rhs.repostAvatarRequest?.url && lhs.theme == rhs.theme && lhs.cs == rhs.cs
  }
  
  //  var disableOuterVSpacing = false
  var id: String
  weak var controller: UIViewController?
  var avatarRequest: ImageRequest?
  var cachedVideo: SharedVideo?
  var repostAvatarRequest: ImageRequest?
  var theme: SubPostsListTheme
  var showSub = false
  var secondary = false
  weak var routerProxy: RouterProxy?
  let contentWidth: CGFloat
  let blurPostLinkNSFW: Bool
  var postSwipeActions: SwipeActionsSet
  let showVotes: Bool
  let showSelfText: Bool
  var readPostOnScroll: Bool
  var hideReadPosts: Bool
  let showUpvoteRatio: Bool
  let showSubsAtTop: Bool
  let showTitleAtTop: Bool
  let compact: Bool
  let thumbnailPositionRight: Bool?
  let voteButtonPositionRight: Bool?
  let showSelfPostThumbnails: Bool
  var cs: ColorScheme
    
  var body: some View {
    
    Group {
      if compact {
        PostLinkCompact(
          controller: controller,
          //                controller: nil,
          avatarRequest: avatarRequest,
          cachedVideo: cachedVideo,
          repostAvatarRequest: repostAvatarRequest,
          theme: theme,
          showSub: showSub,
          secondary: secondary,
          routerProxy: routerProxy,
          contentWidth: contentWidth,
          blurPostLinkNSFW: blurPostLinkNSFW,
          postSwipeActions: postSwipeActions,
          showVotes: showVotes,
          showSelfText: showSelfText,
          readPostOnScroll: readPostOnScroll,
          hideReadPosts: hideReadPosts,
          showUpvoteRatio: showUpvoteRatio,
          showSubsAtTop: showSubsAtTop,
          showTitleAtTop: showTitleAtTop,
          thumbnailPositionRight: thumbnailPositionRight ?? true,
          voteButtonPositionRight: voteButtonPositionRight ?? true,
          showSelfPostThumbnails: showSelfPostThumbnails,
          cs: cs
        )
        .equatable()
      } else {
        PostLinkNormal(
          controller: controller,
          //                controller: nil,
          avatarRequest: avatarRequest,
          cachedVideo: cachedVideo,
          repostAvatarRequest: repostAvatarRequest,
          theme: theme,
          showSub: showSub,
          routerProxy: routerProxy,
          contentWidth: contentWidth,
          blurPostLinkNSFW: blurPostLinkNSFW,
          postSwipeActions: postSwipeActions,
          showVotes: showVotes,
          showSelfText: showSelfText,
          readPostOnScroll: readPostOnScroll,
          hideReadPosts: hideReadPosts,
          showUpvoteRatio: showUpvoteRatio,
          showSubsAtTop: showSubsAtTop,
          showTitleAtTop: showTitleAtTop,
          cs: cs
        )
        .equatable()
      }
    }
  }
}

extension View {
  func postLinkStyle(post: Post, sub: Subreddit, routerProxy: RouterProxy, theme: SubPostsListTheme, size: CGSize, secondary: Bool, isOpen: Binding<Bool>, openPost: @escaping () -> (), readPostOnScroll: Bool, hideReadPosts: Bool, cs: ColorScheme) -> some View {
    let seen = (post.data?.winstonSeen ?? false)
//    let size = CGSize(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
    let fadeReadPosts = theme.theme.unseenType == .fade
    return self
      .padding(EdgeInsets(top: theme.theme.innerPadding.vertical, leading: theme.theme.innerPadding.horizontal, bottom: theme.theme.innerPadding.vertical, trailing: theme.theme.innerPadding.horizontal))
      .frame(width: size.width, height: size.height, alignment: .top)
      .fixedSize()
      .background(PostLinkBG(theme: theme, stickied: post.data?.stickied, secondary: secondary, cs: cs).equatable())
      .mask(RR(theme.theme.cornerRadius, Color.black).equatable())
      .overlay(PostLinkGlowDot(unseenType: theme.theme.unseenType, seen: seen, cs: cs).equatable(), alignment: .topTrailing)
      .scaleEffect(1)
      .contentShape(Rectangle())
//      .gesture(TapGesture().onEnded(openPost))
      .compositingGroup()
      .brightness(isOpen.wrappedValue ? 0.075 : 0)
      .opacity(fadeReadPosts && seen ? 0.6 : 1)
      .contextMenu(menuItems: { PostLinkContext(post: post) }, preview: { PostLinkContextPreview(post: post, sub: sub, routerProxy: routerProxy) })
      .foregroundStyle(.primary)
      .multilineTextAlignment(.leading)
      .onAppear {
        withAnimation { if isOpen.wrappedValue { isOpen.wrappedValue = false } }
        if let bodyAttr = post.winstonData?.postBodyAttr {
          Caches.postsAttrStr.addKeyValue(key: post.id) { bodyAttr }
        }
      }
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
  }
}


struct PostLinkGlowDot: View, Equatable {
  static func == (lhs: PostLinkGlowDot, rhs: PostLinkGlowDot) -> Bool {
    return lhs.unseenType == rhs.unseenType && lhs.seen == rhs.seen && lhs.cs == rhs.cs
  }
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

struct PostLinkBG: View, Equatable {
  static func == (lhs: PostLinkBG, rhs: PostLinkBG) -> Bool {
    return lhs.theme == rhs.theme && lhs.stickied == rhs.stickied && lhs.cs == rhs.cs
  }
  
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
          RR(theme.theme.cornerRadius, .ultraThinMaterial).equatable()
        }
        RoundedRectangle(cornerRadius: theme.theme.cornerRadius, style: .continuous).fill(secondary ? Color("primaryInverted").opacity(0.15) : theme.theme.bg.color.cs(cs).color())
        if (stickied ?? false) {
          RoundedRectangle(cornerRadius: theme.theme.cornerRadius, style: .continuous)
            .stroke(theme.theme.stickyPostBorderColor.color.cs(cs).color(), lineWidth: theme.theme.stickyPostBorderColor.thickness)
        }
      }
    }
    .allowsHitTesting(false)
  }
}



