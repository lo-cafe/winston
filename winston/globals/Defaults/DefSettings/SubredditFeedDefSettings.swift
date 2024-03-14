//
//  SubredditFeedDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Defaults

struct SubredditFeedDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var preferredSort: SubListingSortOption = .best
  var preferredSearchSort: SubListingSortOption = .best
  var compactPerSubreddit: Dictionary<String, Bool> = .init()
  var chunkLoadSize: Int = 25
  var perSubredditSort: Bool = false
  var openOptionsOnTap: Bool = false
  var showPrefixOnFeedTitle: Bool = true
  var subredditSorts: Dictionary<String, SubListingSortOption> = .init()
}
