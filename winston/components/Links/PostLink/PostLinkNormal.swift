//
//  PostLinkNormal.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import NukeUI

struct PostLinkNormalSelftext: View {
  var selftext: String
  var theme: ThemeText
  var cs: ColorScheme
  var body: some View {
    Text(selftext).lineLimit(3)
      .fontSize(theme.size, theme.weight.t)
      .foregroundColor(theme.color.cs(cs).color())
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    //      .id("body")
  }
}

struct PostLinkNormal: View {
//  static func == (lhs: PostLinkNormal, rhs: PostLinkNormal) -> Bool {
//    return lhs.post == rhs.post && lhs.theme == rhs.theme && lhs.cs == rhs.cs
//  }
  
  @ObservedObject var post: Post
  @ObservedObject var winstonData: PostWinstonData
  var controller: UIViewController?
  var avatarRequest: ImageRequest?
  var theme: SubPostsListTheme
  let sub: Subreddit
  var showSub = false
  var secondary = false
  let routerProxy: RouterProxy
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
  var cs: ColorScheme
  
  @State private var isOpen = false
  
  func maskAsRead() async {
    Task(priority: .background) { await post.toggleSeen(true) }
  }
  
  func openPost() {
    withAnimation(nil) { isOpen = true }
    routerProxy.router.path.append(PostViewPayload(post: post, postSelfAttr: nil, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
  }
  
  var body: some View {
    if let data = post.data, let subData = sub.data {
      let seen = (post.data?.winstonSeen ?? false)
      let size = CGSize(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
      let fadeReadPosts = theme.theme.unseenType == .fade
      let over18 = data.over_18 ?? false
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        if showSubsAtTop {
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, subredditIconKit: subData.subredditIconKit, sub: sub, routerProxy: routerProxy, over18: over18)
        }

        if !showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: maskAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
        }
        
        PostLinkTitle(label: data.title.escape, theme: theme.theme.titleText, cs: cs, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
        
        if !data.selftext.isEmpty && showSelfText {
          PostLinkNormalSelftext(selftext: data.selftext, theme: theme.theme.bodyText, cs: cs)
        }
        
        if showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: maskAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
        }
        
        
        if !showSubsAtTop {
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, subredditIconKit: subData.subredditIconKit, sub: sub, routerProxy: routerProxy, over18: over18)
        }
        
        HStack {
          BadgeOpt(avatarRequest: avatarRequest, badgeKit: data.badgeKit, cs: cs, routerProxy: routerProxy, showVotes: false, theme: theme.theme.badge)
//          Badge(cs: cs, routerProxy: routerProxy, showVotes: showVotes, post: post, theme: theme.theme.badge)
          
          Spacer()
          
            if showVotes { VotesCluster(votesKit: data.votesKit, voteAction: post.vote).fontSize(22, .medium) }
          
        }
      }
      .padding(EdgeInsets(top: theme.theme.innerPadding.vertical, leading: theme.theme.innerPadding.horizontal, bottom: theme.theme.innerPadding.vertical, trailing: theme.theme.innerPadding.horizontal))
      .frame(width: size.width, height: size.height, alignment: .top)
      .fixedSize()
      .background(PostLinkBG(theme: theme, stickied: data.stickied, secondary: secondary, cs: cs).equatable())
      .mask(RR(theme.theme.cornerRadius, Color.black).equatable())
      .overlay(PostLinkGlowDot(unseenType: theme.theme.unseenType, seen: seen, cs: cs).equatable(), alignment: .topTrailing)
      .scaleEffect(1)
      .contentShape(Rectangle())
      .gesture(TapGesture().onEnded(openPost))
      .compositingGroup()
      .brightness(isOpen ? 0.075 : 0)
      .opacity(fadeReadPosts && seen ? 0.6 : 1)
      .contextMenu(menuItems: { PostLinkContext(post: post) }, preview: { PostLinkContextPreview(post: post, sub: sub, routerProxy: routerProxy) })
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
//      .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)      
    }
  }
}

//let atr = NSTextAttachment()
//atr.
