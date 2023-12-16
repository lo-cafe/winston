//
//  PostLinkCompact.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI
import Defaults
import NukeUI

struct PostLinkCompactThumbPlaceholder: View, Equatable {
  static func == (lhs: PostLinkCompactThumbPlaceholder, rhs: PostLinkCompactThumbPlaceholder) -> Bool { lhs.theme == rhs.theme }
  var theme: PostLinkTheme.CompactSelftextPostLinkPlaceholderImg

  var body: some View {
    let scaledCompactModeThumbSize = scaledCompactModeThumbSize()
    Group {
      if theme.type == .winston {
        Image(.winstonFlat)
          .resizable()
      } else {
        Image(systemName: "square.text.square")
          .resizable()
      }
    }
    .scaledToFill()
    .padding(scaledCompactModeThumbSize * 0.075)
    .frame(scaledCompactModeThumbSize)
    .foregroundStyle(theme.color())
  }
}

struct PostLinkCompact: View, Equatable, Identifiable {
  static func == (lhs: PostLinkCompact, rhs: PostLinkCompact) -> Bool {
    return lhs.id == rhs.id && lhs.theme == rhs.theme && lhs.contentWidth == rhs.contentWidth && lhs.defSettings == rhs.defSettings
  }
  var id: String
  @EnvironmentObject var post: Post
  @EnvironmentObject var winstonData: PostWinstonData
  @EnvironmentObject var sub: Subreddit
  weak var controller: UIViewController?
  var theme: SubPostsListTheme
  var showSub = false
  var secondary: Bool
  let contentWidth: CGFloat
  let defSettings: PostLinkDefSettings
    
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
      if defSettings.readOnScroll {
        await post.toggleSeen(true, optimistic: true)
      }
      if defSettings.hideOnRead {
        await post.hide(true)
      }
    }
  }
  
  var over18: Bool { post.data?.over_18 ?? false }
  
  @ViewBuilder
  func mediaComponentCall(showURLInstead: Bool = false) -> some View {
    if let data = post.data, let extractedMedia = post.winstonData?.extractedMedia {
      MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: !defSettings.lightboxReadsPost ? nil : markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: defSettings.blurNSFW, showURLInstead: showURLInstead, media: extractedMedia, over18: over18, compact: true, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, maxMediaHeightScreenPercentage: defSettings.maxMediaHeightScreenPercentage, resetVideo: resetVideo)
        .allowsHitTesting(defSettings.isMediaTappable)
    }
  }
  
  @ViewBuilder
  func votesPiece() -> some View {
    if let data = post.data, defSettings.showVotesCluster {
      VotesCluster(votesKit: data.votesKit, voteAction: post.vote, vertical: true, showUpVoteRatio: defSettings.showUpVoteRatio).fontSize(22, .medium)
        .frame(maxHeight: .infinity)
        .fontSize(22, .medium)
    }
  }
  
  @ViewBuilder
  func mediaPiece() -> some View {
    if let extractedMedia = post.winstonData?.extractedMedia {
      if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
        PreviewLink(url: url, compact: true, previewModel: PreviewModel.get(url, compact: true))
      } else {
        mediaComponentCall()
      }
    } else if defSettings.compactMode.showPlaceholderThumbnail {
      PostLinkCompactThumbPlaceholder(theme: theme.theme.compactSelftextPostLinkPlaceholderImg).equatable()
    }
  }
  
  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        HStack(alignment: .top, spacing: theme.theme.verticalElementsSpacing) {
          
          if defSettings.compactMode.voteButtonsSide == .leading { votesPiece() }
          
          if defSettings.compactMode.thumbnailSide == .leading { mediaPiece() }
          
          VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
            VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing / 2) {
              PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
              
              if let extractedMedia = post.winstonData?.extractedMedia {
                if case .repost(let repost) = extractedMedia, let repostData = repost.data, let url = URL(string: "https://reddit.com/r/\(repostData.subreddit)/comments/\(repost.id)") {
                  OnlyURL(url: url)
                }
                mediaComponentCall(showURLInstead: true)
              }
            }
            
            let newCommentsCount = winstonData.seenCommentsCount == nil ? nil : data.num_comments - winstonData.seenCommentsCount!
            BadgeView(avatarRequest: winstonData.avatarImageRequest, showAuthorOnPostLinks: defSettings.showAuthor, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, userFlair: data.badgeKit.userFlair, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.badgeKit.numComments), newCommentsCount: newCommentsCount, votesCount: formatBigNumber(data.badgeKit.ups), likes: data.likes, openSub: !theme.theme.badge.avatar.visible && showSub ? openSubreddit : nil, subName: data.subreddit)
            
            if showSub && theme.theme.badge.avatar.visible {
              let subName = data.subreddit
              Tag(subredditIconKit: nil, text: "r/\(subName)", color: theme.theme.badge.subColor())
                .highPriorityGesture(TapGesture().onEnded(openSubreddit))
            }
                      
          }
          .frame(maxWidth: .infinity, alignment: .topLeading)
          
          if defSettings.compactMode.thumbnailSide == .trailing { mediaPiece() }
          
          if defSettings.compactMode.voteButtonsSide == .trailing { votesPiece() }
        }
        .zIndex(1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
      }
      .postLinkStyle(showSubBottom: showSub && theme.theme.badge.avatar.visible, post: post, sub: sub, theme: theme, size: winstonData.postDimensions.size, secondary: secondary, isOpen: $isOpen, openPost: openPost, readPostOnScroll: defSettings.readOnScroll, hideReadPosts: defSettings.hideOnRead)
      .swipyUI(onTap: openPost, actionsSet: defSettings.swipeActions, entity: post)
//      .frame(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
    }
  }
}
