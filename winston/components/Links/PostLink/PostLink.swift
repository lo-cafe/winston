//
//  Post.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults
import NukeUI



let POSTLINK_INNER_H_PAD: CGFloat = 16

struct PostLink: View, Equatable, Identifiable {
  static func == (lhs: PostLink, rhs: PostLink) -> Bool {
    return lhs.id == rhs.id && lhs.repostAvatarRequest?.url == rhs.repostAvatarRequest?.url && lhs.defSettings == rhs.defSettings && lhs.compactPerSubreddit == rhs.compactPerSubreddit && lhs.theme == rhs.theme && lhs.contentWidth == rhs.contentWidth
  }
  
  //  var disableOuterVSpacing = false
  var id: String
  weak var controller: UIViewController? = nil
  var repostAvatarRequest: ImageRequest?
  var theme: SubPostsListTheme
  var showSub = false
  var secondary = false
  let compactPerSubreddit: Bool?
  let contentWidth: CGFloat
  var defSettings: PostLinkDefSettings = Defaults[.PostLinkDefSettings]
    
  var body: some View {
    
    Group {
      if compactPerSubreddit ?? defSettings.compactMode.enabled {
        PostLinkCompact(
          id: id,
          controller: controller,
          theme: theme,
          showSub: showSub,
          secondary: secondary,
          contentWidth: contentWidth,
          defSettings: defSettings
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
          defSettings: defSettings
        )
        .equatable()
      }
    }
  }
}

extension View {
  func postLinkStyle(showSubBottom: Bool = false, post: Post, sub: Subreddit, theme: PostLinkTheme, size: CGSize, secondary: Bool, openPost: @escaping () -> (), readPostOnScroll: Bool, hideReadPosts: Bool) -> some View {
    let seen = (post.data?.winstonSeen ?? false)
    let fadeReadPosts = theme.unseenType == .fade
    return self
      .padding(EdgeInsets(top: theme.innerPadding.vertical, leading: theme.innerPadding.horizontal, bottom: theme.innerPadding.vertical, trailing: theme.innerPadding.horizontal))
      .background(PostLinkBG(theme: theme, stickied: post.data?.stickied, secondary: secondary))
      .overlay(PostLinkGlowDot(unseenType: theme.unseenType, seen: seen, badge: false), alignment: .topTrailing)
      .contentShape(Rectangle())
      .compositingGroup()
//      .brightness(isOpen.wrappedValue ? 0.075 : 0)
      .opacity(fadeReadPosts && seen ? theme.unseenFadeOpacity : 1)
      .contextMenu(menuItems: {
        PostLinkContext(post: post)
        
        if let permalink = post.data?.permalink, let permaURL = URL(string: "https://reddit.com\(permalink.escape.urlEncoded)") {
          ShareLink(item: permaURL) { Label("Share", systemImage: "square.and.arrow.up") }
        }
        
      }, preview: { PostLinkContextPreview(post: post, sub: sub) })
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
    return lhs.unseenType == rhs.unseenType && lhs.seen == rhs.seen
  }
  let unseenType: UnseenType
  let seen: Bool
  let badge: Bool
  
  var body: some View {
    ZStack {
      switch unseenType {
      case .dot(let color):
        ZStack {
          Circle()
            .fill(badge ? color() : Color.hex("CFFFDE"))
            .frame(width: 5, height: 5)
          Circle()
            .fill(color())
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
    return lhs.theme == rhs.theme && lhs.stickied == rhs.stickied && lhs.secondary == rhs.secondary
  }
  
  let theme: PostLinkTheme
  let stickied: Bool?
  let secondary: Bool
  var body: some View {
    ZStack {
      if !secondary && theme.outerHPadding == 0 {
        theme.bg.color()
        if stickied ?? false {
          theme.stickyPostBorderColor.color()
        }
      } else {
        
        if theme.bg.blurry {
          RR(theme.cornerRadius, .ultraThinMaterial).equatable()
        }
        
        RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous).fill(secondary ? .primary.opacity(0.06) : theme.bg.color())
        
        if (stickied ?? false) {
          RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
            .stroke(theme.stickyPostBorderColor.color(), lineWidth: theme.stickyPostBorderColor.thickness)
        }
        
      }
    }
    .allowsHitTesting(false)
    .mask(RR(theme.cornerRadius, Color.black).equatable())
  }
}



