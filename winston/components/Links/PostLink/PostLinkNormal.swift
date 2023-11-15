//
//  PostLinkNormal.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import NukeUI

struct PostLinkNormalSelftext: View, Equatable {
  static func == (lhs: PostLinkNormalSelftext, rhs: PostLinkNormalSelftext) -> Bool {
    return lhs.selftext == rhs.selftext && lhs.theme == rhs.theme && lhs.cs == rhs.cs
  }
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

struct PostLinkNormal: View, Equatable {
  static func == (lhs: PostLinkNormal, rhs: PostLinkNormal) -> Bool {
    return lhs.theme == rhs.theme && lhs.cs == rhs.cs && lhs.contentWidth == rhs.contentWidth && lhs.avatarRequest?.url == rhs.avatarRequest?.url && lhs.cachedVideo == rhs.cachedVideo && lhs.repostAvatarRequest?.url == rhs.repostAvatarRequest?.url && lhs.blurPostLinkNSFW == rhs.blurPostLinkNSFW && lhs.hideReadPosts == rhs.hideReadPosts
  }
  
  @EnvironmentObject var post: Post
  @EnvironmentObject var winstonData: PostWinstonData
  @EnvironmentObject var sub: Subreddit
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
  var cs: ColorScheme
  
  //  @Environment(\.useTheme) private var selectedTheme
  
  @State private var isOpen = false
  
  func markAsRead() async {
    Task(priority: .background) { await post.toggleSeen(true) }
  }
  
  func openPost() {
    if let routerProxy = routerProxy {
      withAnimation(nil) { isOpen = true }
      routerProxy.router.path.append(PostViewPayload(post: post, postSelfAttr: nil, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
    }
  }
  
  func onDisappear() {
    Task(priority: .background) {
      if readPostOnScroll {
        await post.toggleSeen(true, optimistic: true)
      }
      if hideReadPosts {
        await post.hide(true)
      }
    }
  }
  
  var over18: Bool { post.data?.over_18 ?? false }
  
  @ViewBuilder
  func mediaComponentCall() -> some View {
    if let data = post.data {
      if let extractedMedia = post.winstonData?.extractedMedia {
        MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
      }
    }
  }
  
  var body: some View {
    if let routerProxy = routerProxy, let data = post.data {
      let over18 = data.over_18 ?? false
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        if showSubsAtTop {
          //          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, subredditIconKit: subData.subredditIconKit, sub: sub, routerProxy: routerProxy, over18: over18)
          SubsNStuffLine()
            .equatable()
        }
        
        if !showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          mediaComponentCall()
          
          if case .repost(let repost) = extractedMedia {
            if let repostSub = repost.winstonData?.subreddit, let repostWinstonData = repost.winstonData {
              //                SwipeRevolution(size: repostWinstonData.postDimensions.size, actionsSet: postSwipeActions, entity: repost) { controller in
              PostLink(
                id: repost.id,
                controller: controller,
                avatarRequest: repostAvatarRequest,
                theme: theme,
                showSub: true,
                secondary: true,
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
                compact: false,
                thumbnailPositionRight: nil,
                voteButtonPositionRight: nil,
                showSelfPostThumbnails: false,
                cs: cs
              )
              //                }
              .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
              .environmentObject(repost)
              .environmentObject(repostWinstonData)
              .environmentObject(repostSub)
            }
          }
        }
        PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, cs: cs, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
        
        if !data.selftext.isEmpty && showSelfText {
          PostLinkNormalSelftext(selftext: data.selftext, theme: theme.theme.bodyText, cs: cs)
            .lineSpacing(theme.theme.linespacing)
        }
        
        if showTitleAtTop {
          mediaComponentCall()
        }
        
        
        if !showSubsAtTop {
          //          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, subredditIconKit: subData.subredditIconKit, sub: sub, routerProxy: routerProxy, over18: over18).equatable()
          SubsNStuffLine().equatable()
        }
        //
        HStack {
          BadgeView(avatarRequest: winstonData.avatarImageRequest, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.badgeKit.numComments), votesCount: !showVotes ? nil : formatBigNumber(data.badgeKit.ups), routerProxy: routerProxy, cs: cs)
          
          Spacer()
          
          if showVotes { VotesCluster(votesKit: data.votesKit, voteAction: post.vote).fontSize(22, .medium).drawingGroup() }
          
        }
      }
      .postLinkStyle(post: post, sub: sub, routerProxy: routerProxy, theme: theme, size: winstonData.postDimensions.size, secondary: secondary, isOpen: $isOpen, openPost: openPost, readPostOnScroll: readPostOnScroll, hideReadPosts: hideReadPosts, cs: cs)
      //      .scrollSwipe(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
      .swipyUI(onTap: openPost, actionsSet: postSwipeActions, entity: post)
      //      .onChange(of: selectedTheme) { x in post.setupWinstonData(data: post.data, winstonData: winstonData, theme: x) }
      .frame(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
    }
  }
}

//let atr = NSTextAttachment()
//atr.
