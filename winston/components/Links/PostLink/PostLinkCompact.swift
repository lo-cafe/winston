//
//  PostLinkCompact.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI

struct PostLinkCompact: View {
  var post: Post
  var theme: SubPostsListTheme
  let sub: Subreddit
  var showSub = false
  let routerProxy: RouterProxy
  let contentWidth: CGFloat
  let blurPostLinkNSFW: Bool
  let showVotes: Bool
  let thumbnailPositionRight: Bool
  let voteButtonPositionRight: Bool
  let showUpvoteRatio: Bool
  let showSubsAtTop: Bool
  let over18: Bool
  var cs: ColorScheme
  
  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        if showSubsAtTop {
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
//            .equatable()
//            .id("subs-n-stuff")
        }
        
        HStack(alignment: .top, spacing: theme.theme.verticalElementsSpacing) {
          if showVotes && !voteButtonPositionRight {
            VotesCluster(likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post, vertical: true)
              .frame(maxHeight: .infinity)
              .fontSize(22, .medium)
          }
          
          if !thumbnailPositionRight, let extractedMedia = post.winstonData?.extractedMedia {
            MediaPresenter(blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, post: post, compact: true, contentWidth: contentWidth, routerProxy: routerProxy)
          }
          
          VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing / 2) {
              PostLinkTitle(label: data.title.escape, theme: theme.theme.titleText, cs: cs)

              if let extractedMedia = post.winstonData?.extractedMedia {
                MediaPresenter(blurPostLinkNSFW: blurPostLinkNSFW, showURLInstead: true, media: extractedMedia, post: post, compact: true, contentWidth: contentWidth, routerProxy: routerProxy)
              }
            }
            
            Spacer().frame(minHeight: theme.theme.verticalElementsSpacing, maxHeight: .infinity)
            
            Badge(post: post, theme: theme.theme.badge, extraInfo: [PresetBadgeExtraInfo().commentsExtraInfo(data:data), PresetBadgeExtraInfo().upvotesExtraInfo(data: data)])
          }
          .frame(maxWidth: .infinity, alignment: .topLeading)
          
          if thumbnailPositionRight, let extractedMedia = post.winstonData?.extractedMedia {
            MediaPresenter(blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, post: post, compact: true, contentWidth: contentWidth, routerProxy: routerProxy)
          }
          
          if showVotes && voteButtonPositionRight {
            VotesCluster(likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post, vertical: true)
              .frame(maxHeight: .infinity)
              .fontSize(22, .medium)
          }
        }
        .zIndex(1)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        
        SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
      }
    }
  }
}
