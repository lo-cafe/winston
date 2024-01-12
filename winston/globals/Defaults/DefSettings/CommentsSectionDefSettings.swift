//
//  CommentsSectionDefSettings.swift
//  winston
//
//  Created by Igor Marcossi on 15/12/23.
//

import Defaults

struct CommentsSectionDefSettings: Equatable, Hashable, Codable, Defaults.Serializable {
  var collapseAutoModerator: Bool = false
  var preferredSort: CommentSortOption = .confidence
  var commentSkipper: Bool = true
}
