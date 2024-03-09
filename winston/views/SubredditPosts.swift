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
  
  func caller(_ lastElementId: String?, _ sorting: SubListingSortOption?, _ searchQuery: String?, _ flair: String?) async -> ([RedditEntityType]?, String?)? {
      if let sorting, let result = await subreddit.fetchPosts(sort: sorting, after: lastElementId, searchText: searchQuery, contentWidth: contentWidth, flair: flair), let entity = result.0 {
        return (entity, result.1)
    }
    return nil
  }
  
  var titleFormatted: String {
    return switch subreddit.id {
    case "home": "Home"
    case "saved": "Saved"
    default: "r/\(subreddit.data?.display_name ?? subreddit.id)"
    }
  }
  
    var body: some View {
      RedditListingFeed(feedId: subreddit.id, title: titleFormatted, theme: selectedTheme.postLinks.bg, fetch: caller, initialSorting: SubListingSortOption.best, disableSearch: subreddit.id == "saved", subreddit: subreddit)
    }
}
