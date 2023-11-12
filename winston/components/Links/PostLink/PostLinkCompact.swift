//
//  PostLinkCompact.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import NukeUI

struct PostLinkCompactThumbPlaceholder: View, Equatable {
  static func == (lhs: PostLinkCompactThumbPlaceholder, rhs: PostLinkCompactThumbPlaceholder) -> Bool { true }
  var body: some View {
    Image(.winstonFlat)
      .resizable()
      .scaledToFill()
      .padding(4)
      .frame(scaledCompactModeThumbSize())
      .foregroundStyle(.primary.opacity(0.2))
  }
}

struct PostLinkCompact: View, Equatable {
  static func == (lhs: PostLinkCompact, rhs: PostLinkCompact) -> Bool {
    return lhs.theme == rhs.theme && lhs.cs == rhs.cs && lhs.contentWidth == rhs.contentWidth && lhs.avatarRequest?.url == rhs.avatarRequest?.url && lhs.cachedVideo == rhs.cachedVideo && lhs.repostAvatarRequest?.url == rhs.repostAvatarRequest?.url
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
  var secondary: Bool
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
  let thumbnailPositionRight: Bool
  let voteButtonPositionRight: Bool
  let showSelfPostThumbnails: Bool
  var cs: ColorScheme
  
  @Environment(\.useTheme) private var selectedTheme
  
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
  
  var body: some View {
    if let routerProxy = routerProxy, let data = post.data {
      let over18 = data.over_18 ?? false
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        HStack(alignment: .top, spacing: theme.theme.verticalElementsSpacing) {
          if showVotes && !voteButtonPositionRight {
            VotesCluster(votesKit: data.votesKit, voteAction: post.vote, vertical: true).fontSize(22, .medium)
              .frame(maxHeight: .infinity)
              .fontSize(22, .medium)
          }
          
          if !thumbnailPositionRight {
            if let extractedMedia = post.winstonData?.extractedMedia {
              if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                PreviewLink(url: url, compact: true, previewModel: PreviewModel(url))
              }
              MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
            } else if showSelfPostThumbnails {
              PostLinkCompactThumbPlaceholder().equatable()
            }
          }
          
          VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
            VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing / 2) {
              PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, cs: cs, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
              
              if let extractedMedia = post.winstonData?.extractedMedia {
                if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                  OnlyURL(url: url)
                }
                MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, showURLInstead: true, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
              }
            }
                        
//            BadgeOpt(avatarRequest: avatarRequest, badgeKit: data.badgeKit, cs: cs, routerProxy: routerProxy, showVotes: true, theme: theme.theme.badge)
            BadgeView(avatarRequest: winstonData.avatarImageRequest, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.badgeKit.numComments), votesCount: formatBigNumber(data.badgeKit.ups), routerProxy: routerProxy, cs: cs)
          }
          .frame(maxWidth: .infinity, alignment: .topLeading)
          
          if thumbnailPositionRight {
            if let extractedMedia = post.winstonData?.extractedMedia {
              if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                PreviewLink(url: url, compact: true, previewModel: PreviewModel(url))
              }
              MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
            } else if showSelfPostThumbnails {
              PostLinkCompactThumbPlaceholder().equatable()
            }
          }
          
          if showVotes && voteButtonPositionRight {
            VotesCluster(votesKit: data.votesKit, voteAction: post.vote, vertical: true)
              .frame(maxHeight: .infinity)
              .fontSize(22, .medium)
          }
        }
        .zIndex(1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
      }
      .postLinkStyle(post: post, sub: sub, routerProxy: routerProxy, theme: theme, size: winstonData.postDimensions.size, secondary: secondary, isOpen: $isOpen, openPost: openPost, readPostOnScroll: readPostOnScroll, hideReadPosts: hideReadPosts, cs: cs)
      .swipyUI(onTap: openPost, actionsSet: postSwipeActions, entity: post)
      .frame(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
    }
  }
}
