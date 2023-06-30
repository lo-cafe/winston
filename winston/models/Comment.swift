//
//  CommentData.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Defaults

typealias Comment = GenericRedditEntity<CommentData>

extension Comment {
  func vote(_ action: RedditAPI.VoteAction) {
    
  }
}

struct CommentData: GenericRedditEntityDataType {
  let subreddit_id: String?
//  let approved_at_utc: String?
//  let author_is_blocked: Bool?
//  let comment_type: String?
//  let awarders: [String]?
//  let mod_reason_by: String?
//  let banned_by: String?
//  let author_flair_type: String?
//  let total_awards_received: Int?
//  let subreddit: String?
//  let author_flair_template_id: String?
  let likes: Bool?
  let replies: Either<String, Listing<CommentData>>?
//  let user_reports: [String]?
  let saved: Bool?
  let id: String
//  let banned_at_utc: String?
//  let mod_reason_title: String?
//  let gilded: Int?
//  let archived: Bool?
//  let collapsed_reason_code: String?
//  let no_follow: Bool?
  let author: String?
//  let can_mod_post: Bool?
  let created_utc: Double?
  let send_replies: Bool?
  let parent_id: String?
  let score: Int?
  let author_fullname: String?
  let approved_by: String?
  let mod_note: String?
//  let all_awardings: [String]?
  let collapsed: Bool?
  let body: String?
//  let edited: Bool?
  let top_awarded_type: String?
//  let author_flair_css_class: String?
//  let name: String?
//  let is_submitter: Bool?
  let downs: Int?
//  let author_flair_richtext: [String]?
//  let author_patreon_flair: Bool?
  let body_html: String?
//  let removal_reason: String?
//  let collapsed_reason: String?
//  let distinguished: String?
//  let associated_award: String?
//  let stickied: Bool?
//  let author_premium: Bool?
//  let can_gild: Bool?
//  let gildings: [String: String]?
//  let unrepliable_reason: String?
//  let author_flair_text_color: String?
//  let score_hidden: Bool?
//  let permalink: String?
//  let subreddit_type: String?
//  let locked: Bool?
//  let report_reasons: String?
  let created: Double?
//  let author_flair_text: String?
//  let treatment_tags: [String]?
  let link_id: String?
  let subreddit_name_prefixed: String?
//  let controversiality: Int?
  let depth: Int?
  let author_flair_background_color: String?
  let collapsed_because_crowd_control: String?
  let mod_reports: [String]?
  let num_reports: Int?
  let ups: Int?
}

struct Gildings: Codable {
}

struct CommentSort: Codable, Identifiable {
  var icon: String
  var value: String
  var id: String {
    value
  }
}

enum CommentSortOption: Codable, CaseIterable, Identifiable, Defaults.Serializable {
  var id: String {
    self.rawVal.id
  }
  
  case confidence
  case new
  case top
  case controversial
  case old
  case random
  case qa
  case live
  
  var rawVal: SubListingSort {
    switch self {
    case .confidence:
      return SubListingSort(icon: "flame.fill", value: "confidence")
    case .new:
      return SubListingSort(icon: "newspaper.fill", value: "new")
    case .top:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "top")
    case .controversial:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "controversial")
    case .old:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "old")
    case .random:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "random")
    case .qa:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "qa")
    case .live:
      return SubListingSort(icon: "arrow.up.forward.app.fill", value: "live")
    }
  }
}
