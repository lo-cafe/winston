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
    return lhs.selftext == rhs.selftext && lhs.theme == rhs.theme
  }
  var selftext: String
  var theme: ThemeText
  var body: some View {
    Text(selftext).lineLimit(3)
      .fontSize(theme.size, theme.weight.t)
      .foregroundColor(theme.color())
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    //      .id("body")
  }
}

struct PostLinkNormal: View, Equatable, Identifiable {
  static func == (lhs: PostLinkNormal, rhs: PostLinkNormal) -> Bool {
    return lhs.id == rhs.id && lhs.theme == rhs.theme && lhs.contentWidth == rhs.contentWidth && lhs.secondary == rhs.secondary && lhs.defSettings == rhs.defSettings
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
  let defSettings: PostLinkDefSettings
    
  //  @Environment(\.useTheme) private var selectedTheme
  
  @State private var isOpen = false
  
  func markAsRead() async {
    Task(priority: .background) { await post.toggleSeen(true) }
  }
  
  func openPost() {
    withAnimation(nil) { isOpen = true }
    doThisAfter(0.5, callback: { withAnimation { isOpen = false } })
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
  func mediaComponentCall() -> some View {
    if let data = post.data {
      if let extractedMedia = winstonData.extractedMedia {
        MediaPresenter(postDimensions: $winstonData.postDimensions, controller: controller, postTitle: data.title, badgeKit: data.badgeKit, avatarImageRequest: winstonData.avatarImageRequest, markAsSeen: !defSettings.lightboxReadsPost ? nil : markAsRead, cornerRadius: theme.theme.mediaCornerRadius, blurPostLinkNSFW: defSettings.blurNSFW, media: extractedMedia, over18: over18, compact: false, contentWidth: winstonData.postDimensions.mediaSize?.width ?? 0, maxMediaHeightScreenPercentage: defSettings.maxMediaHeightScreenPercentage, resetVideo: resetVideo)
          .allowsHitTesting(defSettings.isMediaTappable)
        
        if case .repost(let repost) = extractedMedia {
          if let repostWinstonData = repost.winstonData, let repostSub = repostWinstonData.subreddit {
            PostLink(
              id: repost.id,
              controller: controller,
              theme: theme,
              showSub: true,
              secondary: true,
              contentWidth: contentWidth,
              defSettings: defSettings
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
        
        if theme.theme.showDivider && defSettings.dividerPosition == .top { SubsNStuffLine().equatable() }
        
        if defSettings.titlePosition == .bottom { mediaComponentCall() }
        
        PostLinkTitle(attrString: winstonData.titleAttr, label: data.title.escape, theme: theme.theme.titleText, size: winstonData.postDimensions.titleSize, nsfw: over18, flair: data.link_flair_text)
          .padding(.bottom, 5)
        
        if !data.selftext.isEmpty && defSettings.showSelfText {
          PostLinkNormalSelftext(selftext: data.selftext, theme: theme.theme.bodyText)
            .lineSpacing(theme.theme.linespacing)
        }
        
        if defSettings.titlePosition == .top { mediaComponentCall() }
        
        if theme.theme.showDivider && defSettings.dividerPosition == .bottom { SubsNStuffLine().equatable() }
        
        HStack {
          let newCommentsCount = winstonData.seenCommentsCount == nil ? nil : data.num_comments - winstonData.seenCommentsCount!
          BadgeView(avatarRequest: winstonData.avatarImageRequest, showAuthorOnPostLinks: defSettings.showAuthor, saved: data.badgeKit.saved, usernameColor: nil, author: data.badgeKit.author, fullname: data.badgeKit.authorFullname, userFlair: data.badgeKit.userFlair, created: data.badgeKit.created, avatarURL: nil, theme: theme.theme.badge, commentsCount: formatBigNumber(data.num_comments), newCommentsCount: newCommentsCount, votesCount: defSettings.showVotesCluster ? nil : formatBigNumber(data.ups), likes: data.likes, openSub: showSub ? openSubreddit : nil, subName: data.subreddit)
          
          Spacer()
          
          if defSettings.showVotesCluster { VotesCluster(votesKit: data.votesKit, voteAction: post.vote, showUpVoteRatio: defSettings.showUpVoteRatio).fontSize(22, .medium) }
          
        }
      }
      .postLinkStyle(post: post, sub: sub, theme: theme, size: winstonData.postDimensions.size, secondary: secondary, isOpen: $isOpen, openPost: openPost, readPostOnScroll: defSettings.readOnScroll, hideReadPosts: defSettings.hideOnRead)
      .swipyUI(onTap: openPost, actionsSet: defSettings.swipeActions, entity: post, secondary: secondary)
      .frame(width: winstonData.postDimensions.size.width, height: winstonData.postDimensions.size.height)
      .fixedSize()
    }
  }
}

//let atr = NSTextAttachment()
//atr.
