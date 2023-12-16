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
    return lhs.id == rhs.id && lhs.repostAvatarRequest?.url == rhs.repostAvatarRequest?.url && lhs.theme == rhs.theme && lhs.cs == rhs.cs && lhs.compact == rhs.compact
  }
  
  //  var disableOuterVSpacing = false
  var id: String
  weak var controller: UIViewController?
  var repostAvatarRequest: ImageRequest?
  var theme: SubPostsListTheme
  var showSub = false
  var secondary = false
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
          id: id,
          controller: controller,
          theme: theme,
          showSub: showSub,
          secondary: secondary,
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
          id: id,
          controller: controller,
          theme: theme,
          showSub: showSub,
          secondary: secondary,
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
  func postLinkStyle(showSubBottom: Bool = false, post: Post, sub: Subreddit, theme: SubPostsListTheme, size: CGSize, secondary: Bool, isOpen: Binding<Bool>, openPost: @escaping () -> (), readPostOnScroll: Bool, hideReadPosts: Bool, cs: ColorScheme) -> some View {
    let seen = (post.data?.winstonSeen ?? false)
//    let size = CGSize(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
    let fadeReadPosts = theme.theme.unseenType == .fade
    return self
      .padding(EdgeInsets(top: theme.theme.innerPadding.vertical, leading: theme.theme.innerPadding.horizontal, bottom: theme.theme.innerPadding.vertical, trailing: theme.theme.innerPadding.horizontal))
      .frame(width: size.width, height: size.height + (showSubBottom ? Tag.height + theme.theme.verticalElementsSpacing : 0), alignment: .top)
      .fixedSize()
      .background(PostLinkBG(theme: theme, stickied: post.data?.stickied, secondary: secondary, cs: cs).equatable())
//      .mask(RR(theme.theme.cornerRadius, Color.black).equatable())
      .overlay(PostLinkGlowDot(unseenType: theme.theme.unseenType, seen: seen, cs: cs, badge: false).equatable(), alignment: .topTrailing)
      .scaleEffect(1)
      .contentShape(Rectangle())
//      .gesture(TapGesture().onEnded(openPost))
      .compositingGroup()
      .brightness(isOpen.wrappedValue ? 0.075 : 0)
      .opacity(fadeReadPosts && seen ? theme.theme.unseenFadeOpacity : 1)
      .contextMenu(menuItems: { PostLinkContext(post: post) }, preview: { PostLinkContextPreview(post: post, sub: sub) })
      .foregroundStyle(.primary)
      .multilineTextAlignment(.leading)
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
  let badge: Bool
  
  var body: some View {
    ZStack {
      switch unseenType {
      case .dot(let color):
        ZStack {
          Circle()
            .fill(badge ? color.cs(cs).color() : Color.hex("CFFFDE"))
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
    .padding(badge ? .horizontal : .all, badge ? 6 : 11)
    .scaleEffect(seen ? 0.1 : 1)
    .opacity(seen ? 0 : 1)
    .allowsHitTesting(false)
  }
}

struct PostLinkBG: View, Equatable {
  static func == (lhs: PostLinkBG, rhs: PostLinkBG) -> Bool {
    return lhs.theme == rhs.theme && lhs.stickied == rhs.stickied && lhs.cs == rhs.cs && lhs.secondary == rhs.secondary
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
        
        RoundedRectangle(cornerRadius: theme.theme.cornerRadius, style: .continuous).fill(secondary ? .primary.opacity(0.06) : theme.theme.bg.color.cs(cs).color())
        
        if (stickied ?? false) {
          RoundedRectangle(cornerRadius: theme.theme.cornerRadius, style: .continuous)
            .stroke(theme.theme.stickyPostBorderColor.color.cs(cs).color(), lineWidth: theme.theme.stickyPostBorderColor.thickness)
        }
        
      }
    }
    .allowsHitTesting(false)
    .mask(RR(theme.theme.cornerRadius, Color.black).equatable())
  }
}



