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
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme && lhs.lastPostAfter == rhs.lastPostAfter && lhs.selectedTheme == rhs.selectedTheme
  }
  
  var showSub = false
  var lastPostAfter: String?
  weak var subreddit: Subreddit?
  var posts: [Post]
  var searchText: String
  var fetch: (Bool, String?) -> ()
  var selectedTheme: WinstonTheme
  
  @Binding var reachedEndOfFeed: Bool
  
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
  
  @Environment(\.colorScheme) private var cs
  
  //  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  
  var body: some View {
    let isThereDivider = selectedTheme.postLinks.divider.style != .no
    let paddingH = selectedTheme.postLinks.theme.outerHPadding
    let paddingV = selectedTheme.postLinks.spacing / (isThereDivider ? 4 : 2)
    List {
      
      Section {
        ForEach(Array(posts.enumerated()), id: \.self.element.id) { i, post in
          
          if let sub = subreddit ?? post.winstonData?.subreddit, let winstonData = post.winstonData {
            PostLink(
              id: post.id,
              controller: nil,
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
            .environmentObject(sub)
            .environmentObject(post)
            .environmentObject(winstonData)
            .onAppear {
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
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
          
        }
        
        if reachedEndOfFeed {
          EndOfFeedView()
        }
      }
      .listRowSeparator(.hidden)
      .listRowBackground(Color.clear)
      
      Section {
        if lastPostAfter != nil && !reachedEndOfFeed {
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
    .themedListBG(selectedTheme.postLinks.bg)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.never)
    .listStyle(.plain)
  }
}
