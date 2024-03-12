//
//  PostData.swift
//  winston
//
//  Created by Igor Marcossi on 25/01/24.
//

import Foundation

struct PostData: GenericRedditEntityDataType {
  let subreddit: String
  var selftext: String?
  var author_fullname: String? = nil
  var saved: Bool
  let gilded: Int
  let clicked: Bool
  let title: String
  let subreddit_name_prefixed: String
  let hidden: Bool
  var ups: Int
  var downs: Int
  let hide_score: Bool
  var post_hint: String? = nil
  let name: String
  let quarantine: Bool
  var link_flair_text_color: String? = nil
  let upvote_ratio: Double
  let subreddit_type: String
  let total_awards_received: Int
  let is_self: Bool
  let created: Double
  let domain: String
  let allow_live_comments: Bool
  var selftext_html: String? = nil
  let id: String
  let is_robot_indexable: Bool
  let author: String
  let num_comments: Int
  let send_replies: Bool
  var whitelist_status: String? = nil
  let contest_mode: Bool
  let permalink: String
  let url: String
  let subreddit_subscribers: Int
  var created_utc: Double? = nil
  let num_crossposts: Int
  var is_video: Bool? = nil
  var is_gallery: Bool? = nil
  var gallery_data: GalleryData? = nil
  var crosspost_parent_list: [PostData]? = nil
  var media_metadata: [String:MediaMetadataItem?]? = nil
  // Optional properties
  var wls: Int? = nil
  var pwls: Int? = nil
  var link_flair_text: String? = nil
  var thumbnail: String? = nil
  //  let edited: Edited?
  var link_flair_template_id: String? = nil
  var author_flair_text: String? = nil
  var media: Media? = nil
  var approved_at_utc: Int? = nil
  var mod_reason_title: String? = nil
  var top_awarded_type: String? = nil
  var author_flair_background_color: String? = nil
  var approved_by: String? = nil
  var is_created_from_ads_ui: Bool? = nil
  var author_premium: Bool? = nil
  var author_flair_css_class: String? = nil
  var gildings: [String: Int]? = nil
  var content_categories: [String]? = nil
  var mod_note: String? = nil
  var link_flair_type: String? = nil
  var removed_by_category: String? = nil
  var banned_by: String? = nil
  var author_flair_type: String? = nil
  var likes: Bool? = nil
  var stickied: Bool? = nil
  var suggested_sort: String? = nil
  var banned_at_utc: String? = nil
  var view_count: String? = nil
  var archived: Bool? = nil
  var no_follow: Bool? = nil
  var is_crosspostable: Bool? = nil
  var pinned: Bool? = nil
  var over_18: Bool? = nil
  //  let all_awardings: [Awarding]?
  var awarders: [String]? = nil
  var media_only: Bool? = nil
  var can_gild: Bool? = nil
  var spoiler: Bool? = nil
  var locked: Bool? = nil
  var treatment_tags: [String]? = nil
  var visited: Bool? = nil
  var removed_by: String? = nil
  var num_reports: Int? = nil
  var distinguished: String? = nil
  var subreddit_id: String? = nil
  var author_is_blocked: Bool? = nil
  var mod_reason_by: String? = nil
  var removal_reason: String? = nil
  var link_flair_background_color: String? = nil
  var report_reasons: [String]? = nil
  var discussion_type: String? = nil
  var secure_media: Media? = nil
  var secure_media_embed: SecureMediaEmbed? = nil
  var preview: Preview? = nil
  var winstonSeen: Bool? = nil
  var winstonHidden: Bool? = nil
  
  var badgeKit: BadgeKit {
    BadgeKit(
      numComments: num_comments,
      ups: ups,
      saved: saved,
      author: author,
      authorFullname: author_fullname ?? "",
      userFlair: author_flair_text ?? "",
      created: created
    )
  }
  
  var votesKit: VotesKit { VotesKit(ups: ups, ratio: upvote_ratio, likes: likes, id: id) }
}

struct GalleryData: Codable, Hashable {
  let items: [GalleryDataItem]?
}

struct GalleryDataItem: Codable, Hashable, Identifiable {
  let media_id: String
  let id: Double
}

struct MediaMetadataItem: Codable, Hashable, Identifiable {
  let status: String
  let e: String?
  let m: String?
  let p: [MediaMetadataItemSize]?
  let s: MediaMetadataItemSize?
  let id: String?
}

struct MediaMetadataItemSize: Codable, Hashable {
  let x: Int
  let y: Int
  let u: String?
}

struct PreviewImg: Codable, Hashable {
  let url: String?
  let width: Int?
  let height: Int?
  let id: String?
}

struct PreviewImgCollection: Codable, Hashable {
  let source: PreviewImg?
  let resolutions: [PreviewImg]?
  //  let variants: Oembed?
  let id: String?
}

struct RedditVideoPreview: Codable, Hashable {
  let bitrate_kbps: Double?
  let fallback_url: String?
  let height: Double?
  let width: Double?
  let scrubber_media_url: String?
  let dash_url: String?
  let duration: Double?
  let hls_url: String?
  let is_gif: Bool?
  let transcoding_status: String?
}

struct Preview: Codable, Hashable {
  let images: [PreviewImgCollection]?
  let reddit_video_preview: RedditVideoPreview?
  let enabled: Bool?
}

struct Media: Codable, Hashable {
  let type: String?
  let oembed: Oembed?
  let reddit_video: RedditVideo?
}

struct Oembed: Codable, Hashable {
  let provider_url: String?
  let version: String?
  let title: String?
  let type: String?
  let thumbnail_width: Int?
  let height: Int?
  let width: Int?
  let html: String?
  let author_name: String?
  let provider_name: String?
  let thumbnail_url: String?
  let thumbnail_height: Int?
  let author_url: String?
}

struct RedditVideo: Codable, Hashable {
  let bitrate_kbps: Int?
  let fallback_url: String?
  let has_audio: Bool?
  let height: Int?
  let width: Int?
  let scrubber_media_url: String?
  let dash_url: String?
  let duration: Int?
  let hls_url: String?
  let is_gif: Bool?
  let transcoding_status: String?
}

struct SecureMediaEmbed: Codable, Hashable {
  let content: String?
  let width: Int?
  let scrolling: Bool?
  let media_domain_url: String?
  let height: Int?
}

struct Awarding: Codable, Hashable {
  let id: String
  let name: String
  let description: String
  let coin_price: Int
  let coin_reward: Int
  let icon_url: String
  let is_enabled: Bool
  let count: Int
  
  // Optional properties
  let days_of_premium: Int?
  let award_sub_type: String?
  let days_of_drip_extension: Int?
  let icon_height: Int?
  let icon_width: Int?
  let is_new: Bool?
  let subreddit_coin_reward: Int?
  let tier_by_required_awardings: [String: Int]?
  let award_type: String?
  let awardings_required_to_grant_benefits: Int?
  let start_date: Double?
  let end_date: Double?
  let static_icon_height: Int?
  let static_icon_url: String?
  let static_icon_width: Int?
  let subreddit_id: String?
}

enum Edited: Codable {
  case bool(Bool)
  case double(Double)
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let boolValue = try? container.decode(Bool.self) {
      self = .bool(boolValue)
    } else if let doubleValue = try? container.decode(Double.self) {
      self = .double(doubleValue)
    } else {
      throw DecodingError.typeMismatch(Edited.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected value of type Bool or Double"))
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .bool(let boolValue):
      try container.encode(boolValue)
    case .double(let doubleValue):
      try container.encode(doubleValue)
    }
  }
}
