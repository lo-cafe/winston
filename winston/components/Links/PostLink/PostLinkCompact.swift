//
//  PostLinkCompact.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import NukeUI

struct PostLinkCompact: View, Equatable {
  static func == (lhs: PostLinkCompact, rhs: PostLinkCompact) -> Bool {
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
        HStack(alignment: .top, spacing: theme.theme.verticalElementsSpacing) {
          if showVotes && !voteButtonPositionRight {
            VotesCluster(votesKit: data.votesKit, voteAction: post.vote, vertical: true).fontSize(22, .medium)
              .frame(maxHeight: .infinity)
              .fontSize(22, .medium)
          }
          
          if !thumbnailPositionRight, let extractedMedia = post.winstonData?.extractedMedia {
            if case .repost(let repost) = extractedMedia {
              if let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                PreviewLink(url: url, compact: true)
              }
            }
            if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
              PreviewLink(url: url, compact: true)
            }
            MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
          }
          
          VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
            VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing / 2) {
              PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, cs: cs, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
              
              if let extractedMedia = post.winstonData?.extractedMedia {
                if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                  OnlyURL(url: url)
                }
                MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, showURLInstead: true, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
                  .equatable()
              }
            }
                        
//            BadgeOpt(avatarRequest: avatarRequest, badgeKit: data.badgeKit, cs: cs, routerProxy: routerProxy, showVotes: true, theme: theme.theme.badge)
            BadgeView(avatarRequest: avatarRequest, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.badgeKit.numComments), votesCount: formatBigNumber(data.badgeKit.ups), routerProxy: routerProxy, cs: cs)
          }
          .frame(maxWidth: .infinity, alignment: .topLeading)
          
          if thumbnailPositionRight, let extractedMedia = post.winstonData?.extractedMedia {
            if case .repost(let repost) = extractedMedia {
              if let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                PreviewLink(url: url, compact: true)
              }
            }
            if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
              PreviewLink(url: url, compact: true)
            }
            MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, cachedVideo: cachedVideo, imgRequests: winstonData.mediaImageRequest, postTitle: data.title, badgeKit: data.badgeKit, markAsSeen: markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, routerProxy: routerProxy)
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
    }
  }
}
