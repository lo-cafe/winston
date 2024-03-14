//
//  MultiPostsView.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect

enum MultiViewType: Hashable {
  case posts(Multi)
  case info(Multi)
}

struct MultiPostsView: View {
  var multi: Multi
  @State private var loading = true
  @State private var posts: [Post] = []
  @State private var lastPostAfter: String?
  @State private var searchText: String = ""
  @State private var sort: SubListingSortOption = Defaults[.SubredditFeedDefSettings].preferredSort
  @State private var newPost = false
  @State private var filter: String = "flair:All"
//  @State private var customFilter: FilterData?
  @State private var reachedEndOfFeed: Bool = false
  
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
//  @Environment(\.colorScheme) private var cs
	@Environment(\.horizontalSizeClass) private var hSizeClass
  @Default(.SubredditFeedDefSettings) var subFeedSettings
  
  func caller(_ lastElementId: String?, _ sorting: SubListingSortOption?, _ searchQuery: String?, _ flair: String?) async -> ([RedditEntityType]?, String?)? {
    
      if let sorting, let result = await multi.fetchPosts(sort: sorting, after: lastElementId, contentWidth: contentWidth), let newPosts = result.0 {
        return (newPosts, result.1)
    }
    return nil
  }
  
  var body: some View {
    RedditListingFeed(feedId: multi.id, showSubInPosts: true, title: "\(subFeedSettings.showPrefixOnFeedTitle ? "m/" : "")\(multi.data?.name ?? "Multi")", theme: selectedTheme.postLinks.bg, fetch: caller, initialSorting: subFeedSettings.preferredSort, disableSearch: true)
  }
}
