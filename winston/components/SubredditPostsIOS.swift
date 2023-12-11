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
    lhs.posts.count == rhs.posts.count && lhs.subreddit?.id == rhs.subreddit?.id && lhs.searchText == rhs.searchText && lhs.selectedTheme == rhs.selectedTheme && lhs.lastPostAfter == rhs.lastPostAfter && lhs.filter == rhs.filter && lhs.loading == rhs.loading && lhs.filters == rhs.filters
  }
  
  var showSub = false
  var lastPostAfter: String?
  weak var subreddit: Subreddit?
  var filters: [FilterData]
  var posts: [Post]
  var filter: String
  var filterCallback: ((String) -> ())
  var searchText: String
  var searchCallback: ((String?) -> ())
  var editCustomFilter: ((FilterData) -> ())
  var fetch: (Bool, String?, Bool) -> ()
  var selectedTheme: WinstonTheme
  var loading: Bool
  
  @Binding var reachedEndOfFeed: Bool
  
  @Default(.blurPostLinkNSFW) private var blurPostLinkNSFW
  
  @Default(.postSwipeActions) private var postSwipeActions
  @Default(.compactPerSubreddit) private var compactPerSubreddit
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
  
  func loadMorePosts() {
    if !searchText.isEmpty {
      fetch(true, searchText, true)
    } else {
      fetch(true, nil, true)
    }
  }
  
  var body: some View {
    let isThereDivider = selectedTheme.postLinks.divider.style != .no
    let paddingH = selectedTheme.postLinks.theme.outerHPadding
    let paddingV = selectedTheme .postLinks.spacing / (isThereDivider ? 4 : 2)
    
    List {
      
      if !selectedTheme.postLinks.stickyFilters, let sub = subreddit {
        SubredditFilters(subId: sub.id, filters: filters, selected: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter, theme: selectedTheme)
          .equatable()
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          .listRowSeparator(.hidden)
      }
      
      Section(
        header: subreddit != nil && selectedTheme.postLinks.stickyFilters ?
        SubredditFilters(subId: subreddit!.id, filters: filters, selected: filter, filterCallback: filterCallback, searchText: searchText, searchCallback: searchCallback, editCustomFilter: editCustomFilter, theme: selectedTheme)
          .equatable()
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        : nil
      ) {
        ForEach(Array(posts.enumerated()), id: \.self.element.id) { i, post in
          if let sub = subreddit ?? post.winstonData?.subreddit, let winstonData = post.winstonData {
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
              compact: compactPerSubreddit[sub.id] ?? compactMode,
              thumbnailPositionRight: thumbnailPositionRight,
              voteButtonPositionRight: voteButtonPositionRight,
              showSelfPostThumbnails: showSelfPostThumbnails,
              cs: cs
            )
            .environmentObject(sub)
            .environmentObject(post)
            .environmentObject(winstonData)
            .onAppear {
              if(posts.count - 7 == i) { loadMorePosts() }
            }
            .listRowInsets(EdgeInsets(top: paddingV, leading: paddingH, bottom: paddingV, trailing: paddingH))
          }
          
          if selectedTheme.postLinks.divider.style != .no && i != (posts.count - 1) {
            NiceDivider(divider: selectedTheme.postLinks.divider)
              .id("\(post.id)-divider")
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
          }
        }
        
        if filter != "flair:All" && posts.count == 0 {
          Text("No filtered posts")
            .frame(maxWidth: .infinity)
            .font(Font.system(size: 22, weight: .semibold))
            .opacity(0.5)
            .padding(.vertical, 24)
            .background(RR(12, Color.primary.opacity(0.1)))
        }
        
        if filter != "flair:All" && !loading && !reachedEndOfFeed  {
          Button(action: {
            loadMorePosts()
          }) {
            Label("LOAD MORE", systemImage: "arrow.clockwise.circle.fill")
              .frame(maxWidth: .infinity)
              .font(Font.system(size: 16, weight: .bold))
              .foregroundStyle(selectedTheme.general.accentColor.cs(cs).color())
              .padding(.top, 12)
              .padding(.bottom, 48)
          }
          
        } else if reachedEndOfFeed {
          EndOfFeedView()
        }
      }
      .listRowSeparator(.hidden)
      .listSectionSeparator(.hidden)
      .listRowBackground(Color.clear)
      
      Section {
        if loading {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: posts.count > 0 || filter != "flair:All" ? 100 : UIScreen.screenHeight - 300 )
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
            .id(UUID())
        }
      }
    }
    .themedListBG(selectedTheme.postLinks.bg)
    .environment(\.defaultMinListHeaderHeight, 0.1)
    .scrollContentBackground(.hidden)
    .scrollIndicators(.never)
    .listStyle(.plain)
    .listRowSeparator(.hidden)
    .listSectionSeparator(.hidden)
    .background(.blue)
  }
}
