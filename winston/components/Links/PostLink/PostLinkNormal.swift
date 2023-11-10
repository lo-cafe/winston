//
//  PostLinkNormal.swift
//  winston
//
//  Created by Igor Marcossi on 25/09/23.
//

import SwiftUI

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
  var post: Post
  var theme: SubPostsListTheme
  let sub: Subreddit
  var showSub = false
  let routerProxy: RouterProxy
  let contentWidth: CGFloat
  let blurPostLinkNSFW: Bool
  let showVotes: Bool
  let showUpvoteRatio: Bool
  let showSubsAtTop: Bool
  let showSelfText: Bool
  let showTitleAtTop: Bool
  let over18: Bool
  var cs: ColorScheme
  
  var body: some View {
    if let data = post.data {
      VStack(alignment: .leading, spacing: theme.theme.verticalElementsSpacing) {
        if showSubsAtTop {
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
        }
        
        if !showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          MediaPresenter(blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, post: post, compact: false, contentWidth: contentWidth, routerProxy: routerProxy)
        }
        
        PostLinkTitle(label: data.title.escape, theme: theme.theme.titleText, cs: cs)
//          .background(GeometryReader { geo in Color.clear.onAppear { print(data.title, "title", post.winstonData?.postDimensions?.titleSize.height, geo.size.height) } })
        
        if !data.selftext.isEmpty && showSelfText {
          PostLinkNormalSelftext(selftext: data.selftext, theme: theme.theme.bodyText, cs: cs)
                .lineSpacing(theme.theme.linespacing)
//            .background(GeometryReader { geo in Color.clear.onAppear { print(data.title, "body", post.winstonData?.postDimensions?.bodySize?.height, geo.size.height) } })
        }
        
        if showTitleAtTop, let extractedMedia = post.winstonData?.extractedMedia {
          MediaPresenter(blurPostLinkNSFW: blurPostLinkNSFW, media: extractedMedia, post: post, compact: false, contentWidth: contentWidth, routerProxy: routerProxy)
//            .background(GeometryReader { geo in Color.clear.onAppear { print(data.title, "media", post.winstonData?.postDimensions?.mediaSize?.height, geo.size.height) } })
        }
        
        
        if !showSubsAtTop {
          SubsNStuffLine(showSub: showSub, feedsAndSuch: feedsAndSuch, post: post, sub: sub, routerProxy: routerProxy, over18: over18)
//            .background(GeometryReader { geo in Color.clear.onAppear { print(data.title, "divider", post.winstonData?.postDimensions?.dividerSize.height, geo.size.height) } })
        }
        
        HStack {
          Badge(post: post, theme: theme.theme.badge, extraInfo: !showVotes ? [PresetBadgeExtraInfo().commentsExtraInfo(data: data), PresetBadgeExtraInfo().upvotesExtraInfo(data: data)] : [PresetBadgeExtraInfo().commentsExtraInfo(data: data)])
          
          Spacer()
          
          HStack(alignment: .center) {
            if showVotes { VotesCluster(likeRatio: showUpvoteRatio ? data.upvote_ratio : nil, post: post).id("votes-cluster") }
          }
          .fontSize(22, .medium)
        }
//        .background(GeometryReader { geo in Color.clear.onAppear { print(data.title, "badge", post.winstonData?.postDimensions?.badgeSize.height, geo.size.height) } })
      }
    }
  }
}
