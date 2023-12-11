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
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme && lhs.filter == rhs.filter
  }
  
  var showSub = false
  var subreddit: Subreddit?
  var posts: [Post]
  var filter: String
  var filterCallback: ((String) -> ())
  var searchText: String
  var searchCallback: ((String?) -> ())
  var editCustomFilter: ((FilterData) -> ())
  var fetch: (Bool, String?, Bool) -> ()
  var selectedTheme: WinstonTheme
  
  @State var lastPostOnRefreshRequest = ""
  
  @Environment(\.contentWidth) var contentWidth
  
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
  
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    VStack(spacing: 8) {
      
      if let sub = subreddit {
        SubredditFilters(subId: sub.id, filters: sub.winstonData?.flairs ?? [], selected: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter, theme: selectedTheme)
      }
      
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
            if let sub = subreddit ?? post.winstonData?.subreddit, let winstonData = post.winstonData {
              //                SwipeRevolution(size: winstonData.postDimensions.size, actionsSet: postSwipeActions, entity: post) { controller in
              PostLink(
                id: post.id,
                controller: nil,
                theme: selectedTheme.postLinks,
                showSub: showSub,
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
              .onAppear {
                if(posts.count - 7 == i) {
                  if !searchText.isEmpty {
                    fetch(true, searchText, true)
                  } else {
                    fetch(true, nil, true)
                  }
                }
              }
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
}
