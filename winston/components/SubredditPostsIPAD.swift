//
//  SubredditPostsIPAD.swift
//  winston
//
//  Created by Igor Marcossi on 28/09/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect
import NukeUI

struct SubredditPostsIPAD: View, Equatable {
  static func == (lhs: SubredditPostsIPAD, rhs: SubredditPostsIPAD) -> Bool {
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme
  }
  
  var showSub = false
  var subreddit: Subreddit?
  var posts: [Post]
  var searchText: String
  var fetch: (Bool, String?) -> ()
  var selectedTheme: WinstonTheme
  @Environment(\.contentWidth) var contentWidth
  @EnvironmentObject private var routerProxy: RouterProxy
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactMode) private var compactMode
  @Default(.showVotes) private var showVotes
  @Default(.showSelfText) private var showSelfText
  @Default(.thumbnailPositionRight) private var thumbnailPositionRight
  @Default(.voteButtonPositionRight) private var voteButtonPositionRight
  
  @Default(.readPostOnScroll) private var readPostOnScroll
  @Default(.hideReadPosts) private var hideReadPosts
  
  @Default(.showUpvoteRatio) private var showUpvoteRatio
  
  @Default(.showSubsAtTop) private var showSubsAtTop
  @Default(.showTitleAtTop) private var showTitleAtTop
  @Default(.showSelfPostThumbnails) private var showSelfPostThumbnails
  
  @ObservedObject var avatarCache = Caches.avatars
  @ObservedObject private var videosCache = Caches.videos
  @Environment(\.colorScheme) private var cs
  
  func getRepostAvatarRequest(_ post: Post?) -> ImageRequest? {
    if let post = post, case .repost(let repost) = post.winstonData?.extractedMedia, let repostAuthorFullname = repost.data?.author_fullname {
      return avatarCache.cache[repostAuthorFullname]?.data
    }
    return nil
  }
  
  var body: some View {
        Waterfall(
          collection: posts,
          scrollDirection: .vertical,
          contentSize: .custom({ collectionView, layout, post in
            post.winstonData?.postDimensions.size ?? CGSize(width: 300, height: 300)
          }),
//          itemSpacing: .init(mainAxisSpacing: selectedTheme.postLinks.spacing, crossAxisSpacing: selectedTheme.postLinks.spacing),
//          itemSpacing: .init(mainAxisSpacing: 0, crossAxisSpacing: 0),
          contentForData: { post, i in
            Group {
              if let sub = subreddit ?? post.winstonData?.subreddit, let postData = post.data, let winstonData = post.winstonData {
//                SwipeRevolution(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post) { controller in
                  PostLink(
                    id: post.id,
                    controller: nil,
                    //                controller: nil,
                    avatarRequest: avatarCache.cache[postData.author_fullname ?? ""]?.data,
                    cachedVideo: videosCache.cache[post.id]?.data,
                    repostAvatarRequest: getRepostAvatarRequest(post),
                    theme: selectedTheme.postLinks,
                    showSub: showSub,
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
                    compact: compactMode,
                    thumbnailPositionRight: thumbnailPositionRight,
                    voteButtonPositionRight: voteButtonPositionRight,
                    showSelfPostThumbnails: showSelfPostThumbnails,
                    cs: cs
                  )
                  .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
                  .environmentObject(post)
                  .environmentObject(sub)
                  .environmentObject(winstonData)
//                }
              }
            }
          },
          theme: selectedTheme.postLinks
        )
        .ignoresSafeArea()
//      .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { scrollView in
//        scrollView.backgroundColor = UIColor.systemGroupedBackground
//      }
  }
}
