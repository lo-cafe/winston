//
//  PostPageDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Defaults

struct PostPageDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var blurNSFW: Bool = false
  var preferredSearchSort: SubListingSortOption = .best
  var perPostSort: Bool = false
  var postSorts: Dictionary<String, CommentSortOption> = .init()
  var showUpVoteRatio: Bool = true
}
