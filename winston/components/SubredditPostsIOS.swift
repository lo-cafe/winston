//
//  SubredditPostsIOS.swift
//  winston
//
//  Created by Igor Marcossi on 28/09/23.
//

import SwiftUI
import Defaults
import NukeUI

struct SubredditPostsIOS: View, Equatable {
  static func == (lhs: SubredditPostsIOS, rhs: SubredditPostsIOS) -> Bool {
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme && lhs.lastPostAfter == rhs.lastPostAfter
  }
  
  var showSub = false
  var lastPostAfter: String?
  weak var subreddit: Subreddit?
  var posts: [Post]
  var searchText: String
  var fetch: (Bool, String?) -> ()
  var selectedTheme: WinstonTheme
  
  @EnvironmentObject private var routerProxy: RouterProxy
  @ObservedObject var avatarCache = Caches.avatars
  @ObservedObject private var videosCache = Caches.videos
  
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
  
  @Environment(\.colorScheme) private var cs
  
  //  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  
  func getRepostAvatarRequest(_ post: Post?) -> ImageRequest? {
    if let post = post, case .repost(let repost) = post.winstonData?.extractedMedia, let repostAuthorFullname = repost.data?.author_fullname {
      return avatarCache.cache[repostAuthorFullname]?.data
    }
    return nil
  }
  
  var body: some View {
    let paddingH = selectedTheme.postLinks.theme.outerHPadding
    let paddingV = selectedTheme.postLinks.spacing / 2
    List {
      Section {
//        CollectionView(collection: posts, scrollDirection: .vertical, contentSize: .custom({ collectionView, layout, post in
//          post.winstonData?.postDimensions.size ?? CGSize(width: 300, height: 300)
//        }), itemSpacing: .init(mainAxisSpacing: selectedTheme.postLinks.spacing, crossAxisSpacing: 0)) { post, controller, i, total in
         ForEach(Array(posts.enumerated()), id: \.self.element.id) { i, post in
          
          if let sub = subreddit ?? post.winstonData?.subreddit, let postData = post.data, let winstonData = post.winstonData {
//             { controller in
              PostLink(
                id: post.id,
                controller: nil,
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
                cs: cs
              )
//              .swipyUI(actionsSet: postSwipeActions, entity: post)
//              .equatable()
              .environmentObject(sub)
              .environmentObject(post)
              .environmentObject(winstonData)
//              .swipyRev(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post)
//              .id("\(post.id)-post-link")
//            }
            //              .equatable()
            .onAppear {
              //              print("maos", i, total)
              //              if(total - 7 == i) {
              if(posts.count - 7 == i) {
                if !searchText.isEmpty {
                  fetch(true, searchText)
                } else {
                  fetch(true, nil)
                }
              }
            }
            .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
          }
          
          if selectedTheme.postLinks.divider.style != .no && i != (posts.count - 1) {
            NiceDivider(divider: selectedTheme.postLinks.divider)
              .id("\(post.id)-divider")
          }
          
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      
      Section {
        if lastPostAfter != nil {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: posts.count > 0 ? 100 : UIScreen.screenHeight - 200 )
            .id("post-loading")
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
      }
      
    }
    //    .ignoresSafeArea()
    .themedListBG(selectedTheme.postLinks.bg)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.never)
    .listStyle(.plain)
  }
}
