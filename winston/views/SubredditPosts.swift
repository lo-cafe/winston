//
//  SubredditPosts.swift
//  winston
//
//  Created by Igor Marcossi on 26/01/24.
//

import SwiftUI

struct SubredditPosts: View, Equatable {
  static func == (lhs: SubredditPosts, rhs: SubredditPosts) -> Bool {
    lhs.subreddit == rhs.subreddit
  }
  
  var subreddit: Subreddit
  
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.contentWidth) private var contentWidth
  
  func caller(_ lastElementId: String?, _ sorting: SubListingSortOption, _ searchQuery: String?, _ flair: String?) async -> [RedditEntityType]? {
    if let result = await subreddit.fetchPosts(sort: sorting, after: lastElementId, searchText: searchQuery, contentWidth: contentWidth, flair: flair), let posts = result.0 {
      return posts.map { RedditEntityType.post($0) }
    }
    return nil
  }
  
    var body: some View {
      RedditListingFeed(feedId: subreddit.id, title: "r/\(subreddit.data?.display_name ?? subreddit.id)", theme: selectedTheme.postLinks.bg, fetch: caller, initialSorting: SubListingSortOption.best, subreddit: subreddit)
    }
}
