//
//  PostLinkNormal.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import Defaults
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

struct PostLinkNormal: View, Equatable, Identifiable {
  static func == (lhs: PostLinkNormal, rhs: PostLinkNormal) -> Bool {
    return lhs.id == rhs.id && lhs.theme == rhs.theme && lhs.cs == rhs.cs && lhs.contentWidth == rhs.contentWidth && lhs.blurPostLinkNSFW == rhs.blurPostLinkNSFW && lhs.hideReadPosts == rhs.hideReadPosts && lhs.secondary == rhs.secondary
  }
  
  @EnvironmentObject var post: Post
  @EnvironmentObject var winstonData: PostWinstonData
  @EnvironmentObject var sub: Subreddit
  var id: String
  weak var controller: UIViewController?
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
  var cs: ColorScheme
  
  @Default(.showAuthorOnPostLinks) private var showAuthorOnPostLinks
  @Default(.tappableFeedMedia) private var tappableFeedMedia
  
  //  @Environment(\.useTheme) private var selectedTheme
  
  @State private var isOpen = false
  
  func markAsRead() async {
    Task(priority: .background) { await post.toggleSeen(true) }
  }
  
  func openPost() {
      withAnimation(nil) { isOpen = true }
      Nav.to(.reddit(.post(post)))
  }
  
  func openSubreddit() {
    if let subName = post.data?.subreddit {
      Nav.to(.reddit(.subFeed(Subreddit(id: subName))))
    }
  }
  
  func resetVideo(video: SharedVideo) {
    DispatchQueue.main.async {
      let newVideo: MediaExtractedType = .video(SharedVideo.get(url: video.url, size: video.size, resetCache: true))
      post.winstonData?.extractedMedia = newVideo
      post.winstonData?.extractedMediaForcedNormal = newVideo

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
      if let extractedMedia = winstonData.extractedMedia {
        MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, resetVideo: resetVideo)
          .allowsHitTesting(tappableFeedMedia)
        
        if case .repost(let repost) = extractedMedia {
          if let repostWinstonData = repost.winstonData, let repostSub = repostWinstonData.subreddit {
            PostLink(
              id: repost.id,
              controller: controller,
              theme: theme,
              showSub: true,
              secondary: true,
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
            .background(Color.primary.opacity(0.05))
            .cornerRadius(theme.theme.mediaCornerRadius)
            //                }
            //            .swipyRev(size: repostWinstonData.postDimensions.size, actionsSet: postSwipeActions, entity: repost)
            .environmentObject(repost)
            .environmentObject(repostWinstonData)
            .environmentObject(repostSub)
          }
        }
      }
    }
  }
  
  var body: some View {
    if let data = post.data {
      let over18 = data.over_18 ?? false
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        
        if theme.theme.showDivider && showSubsAtTop { SubsNStuffLine().equatable() }
        
        if !showTitleAtTop { mediaComponentCall() }
        
        PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, cs: cs, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
          .padding(.bottom, 5)
        
        if !data.selftext.isEmpty && showSelfText {
          PostLinkNormalSelftext(selftext: data.selftext, theme: theme.theme.bodyText, cs: cs)
            .lineSpacing(theme.theme.linespacing)
        }
        
        if showTitleAtTop { mediaComponentCall() }
        
        if theme.theme.showDivider && !showSubsAtTop { SubsNStuffLine().equatable() }
        
        HStack {
          let newCommentsCount = winstonData.seenCommentsCount == nil ? nil : data.num_comments - winstonData.seenCommentsCount!
          BadgeView(avatarRequest: winstonData.avatarImageRequest, showAuthorOnPostLinks: showAuthorOnPostLinks, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, userFlair: data.badgeKit.userFlair, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.num_comments), newCommentsCount: newCommentsCount, votesCount: showVotes ? nil : formatBigNumber(data.ups), likes: data.likes, cs: cs, openSub: showSub ? openSubreddit : nil, subName: data.subreddit)
          
          Spacer()
          
          if showVotes { VotesCluster(votesKit: data.votesKit, voteAction: post.vote).fontSize(22, .medium) }
          
        }
      }
      .postLinkStyle(post: post, sub: sub, theme: theme, size: winstonData.postDimensions.size, secondary: secondary, isOpen: $isOpen, openPost: openPost, readPostOnScroll: readPostOnScroll, hideReadPosts: hideReadPosts, cs: cs)
      .swipyUI(onTap: openPost, actionsSet: postSwipeActions, entity: post, secondary: secondary)
      .frame(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
      .fixedSize()
    }
  }
}

//let atr = NSTextAttachment()
//atr.
