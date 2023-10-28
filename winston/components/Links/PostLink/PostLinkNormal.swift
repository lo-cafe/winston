//
//  PostLinkNormal.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import NukeUI

struct PostLinkNormalSelftext: View, Equatable {
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
    return lhs.post == rhs.post && lhs.theme == rhs.theme && lhs.cs == rhs.cs && lhs.contentWidth == rhs.contentWidth
  }
  
  @ObservedObject var post: Post
  @ObservedObject var winstonData: PostWinstonData
  weak var controller: UIViewController?
  var avatarRequest: ImageRequest?
  var cachedVideo: SharedVideo?
  var repostAvatarRequest: ImageRequest?
  var theme: SubPostsListTheme
  weak var sub: Subreddit?
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
  
  @State private var isOpen = false
  
  func markAsRead() async {
    Task(priority: .background) { await post.toggleSeen(true) }
  }
  
  func openPost() {
    if let sub = sub, let routerProxy = routerProxy {
      withAnimation(nil) { isOpen = true }
      routerProxy.router.path.append(PostViewPayload(post: post, postSelfAttr: nil, sub: feedsAndSuch.contains(sub.id) ? sub : sub))
    }
  }
  
  var body: some View {
    if let data = post.data {
      let over18 = data.over_18 ?? false
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        if showSubsAtTop {
//          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, subredditIconKit: subData.subredditIconKit, sub: sub, routerProxy: routerProxy, over18: over18)
          SubsNStuffLine()
            .equatable()
        }
        
        if !showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
          
          if case .repost(let repost) = extractedMedia {
            if let repostSub = repost.winstonData?.subreddit, let repostWinstonData = repost.winstonData {
                SwipeRevolution(size: repostWinstonData.postDimensions.size, actionsSet: postSwipeActions, entity: repost) { controller in
                  PostLink(
                    post: repost,
                    controller: controller,
                    avatarRequest: repostAvatarRequest,
                    theme: theme,
                    sub: repostSub,
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
                    cs: cs
                  )
                }
              }
          }
        }
        PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, cs: cs, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
        
        if !data.selftext.isEmpty && showSelfText {
          PostLinkNormalSelftext(selftext: data.selftext, theme: theme.theme.bodyText, cs: cs)
        }
        
        if showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
        }
        
        
        if !showSubsAtTop {
//          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, subredditIconKit: subData.subredditIconKit, sub: sub, routerProxy: routerProxy, over18: over18).equatable()
          SubsNStuffLine().equatable()
        }
//        
        HStack {
          BadgeView(avatarRequest: avatarRequest, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.badgeKit.numComments), votesCount: !showVotes ? nil : formatBigNumber(data.badgeKit.ups), routerProxy: routerProxy, cs: cs)
          
          Spacer()
          
          if showVotes { VotesCluster(votesKit: data.votesKit, voteAction: post.vote).fontSize(22, .medium).drawingGroup() }
          
        }
      }

    }
  }
}

//let atr = NSTextAttachment()
//atr.
