//
//  SubredditData.swift
//  winston
//
//  Created by Igor Marcossi on 26/06/23.
//

import Foundation
import CoreData
import Defaults
import SwiftUI


typealias Subreddit = GenericRedditEntity<SubredditData, AnyHashable>

extension Subreddit {
  static var prefix = "t5"
  var selfPrefix: String { Self.prefix }
  convenience init(data: T, api: RedditAPI) {
    self.init(data: data, api: api, typePrefix: "\(Subreddit.prefix)_")
    
    saveSubredditIconToDefaults(name: self.data?.display_name, data: self.data)
  }
  
  convenience init(id: String, api: RedditAPI) {
    self.init(id: id, api: api, typePrefix: "\(Subreddit.prefix)_")
  }
  
  convenience init(entity: CachedSub, api: RedditAPI) {
    self.init(id: entity.uuid ?? UUID().uuidString, api: api, typePrefix: "\(Subreddit.prefix)_")
    self.data = SubredditData(entity: entity)
    
    saveSubredditIconToDefaults(name: self.data?.display_name, data: self.data)
  }
  
  func saveSubredditIconToDefaults(name: String?, data: SubredditData?) {
    if data?.community_icon != nil || data?.icon_img != nil, let displayName = name {
      Defaults[.subredditIcons][displayName] = [ "community_icon" : data!.community_icon, "icon_img" : data!.icon_img ]
    }
  }
  
  /// Add a subreddit to the local like list
  /// This is a seperate list from reddits liked intenden for usage with subreddits a user wants to favorite but not subscribe to
  /// returns true if added to favorites and false if removed
  func localFavoriteToggle() -> Bool {
    var likedButNotSubbed = Defaults[.likedButNotSubbed]
    // If the user is not subscribed
    
    // If its already in liked remove it
    if likedButNotSubbed.contains(self) {
      likedButNotSubbed = likedButNotSubbed.filter{ $0.id != self.id }
      return false
    } else { // Else add it
      Defaults[.likedButNotSubbed].append(self)
      return true
    }
  }
  
  func favoriteToggle(entity: CachedSub? = nil) {
    if let entity = entity, let name = data?.display_name {
      let favoritedStatus = entity.user_has_favorited
      if let context = entity.managedObjectContext {
        entity.user_has_favorited = !favoritedStatus
        withAnimation {
          self.data?.user_has_favorited = !favoritedStatus
          try? context.save()
        }
        
        Task {
          let result = await RedditAPI.shared.favorite(!favoritedStatus, subName: name)
          if !result {
            entity.user_has_favorited = favoritedStatus
            withAnimation {
              self.data?.user_has_favorited = favoritedStatus
              try? context.save()
            }
          }
        }
      }
    }
  }
  
  
  
  func subscribeToggle(optimistic: Bool = false, _ cb: (()->())? = nil) {
    let context = PersistenceController.shared.container.viewContext
    
    if let data = data {
      @Sendable func doToggle() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedSub")
        guard let results = (context.performAndWait { return try? context.fetch(fetchRequest) as? [CachedSub] }) else { return }
        let foundSub = context.performAndWait { results.first(where: { $0.name == self.data?.name }) }
        
        withAnimation {
          self.data?.user_is_subscriber?.toggle()
        }
        if let foundSub = foundSub { // when unsubscribe
          context.delete(foundSub)
        } else if let newData = self.data {
          context.performAndWait {
            _ = CachedSub(data: newData, context: context)
          }
        }
      }
      
      //      let likedButNotSubbed = Defaults[.likedButNotSubbed]
      if optimistic {
        doToggle()
        context.performAndWait {
          withAnimation {
            try? context.save()
          }
        }
      }
      Task(priority: .background) {
        let result = await RedditAPI.shared.subscribe((self.data?.user_is_subscriber ?? false) ? (optimistic ? .sub : .unsub) : (optimistic ? .unsub : .sub), subFullname: data.name)
        context.performAndWait {
          if (result && !optimistic) || (!result && optimistic) {
            doToggle()
          }
          context.performAndWait {
            withAnimation {
              try? context.save()
            }
          }
          cb?()
        }
      }
    }
  }
  
  func getFlairs() async -> [Flair]? {
    if let data = (await RedditAPI.shared.getFlairs(data?.display_name ?? id)) {
      await MainActor.run {
        withAnimation {
          self.data?.winstonFlairs = data
        }
      }
    }
    return nil
  }
  
  func refreshSubreddit() async {
    if let data = (await RedditAPI.shared.fetchSub(data?.display_name ?? id))?.data {
      await MainActor.run {
        withAnimation {
          self.data = data
        }
      }
    }
  }
  
  func fetchRules() async -> RedditAPI.FetchSubRulesResponse? {
    if let data = await RedditAPI.shared.fetchSubRules(data?.display_name ?? id) {
      return data
    }
    return nil
  }
  
  func fetchPosts(sort: SubListingSortOption = .best, after: String? = nil, searchText: String? = nil, contentWidth: CGFloat = UIScreen.screenWidth) async -> ([Post]?, String?)? {
    if let response = await RedditAPI.shared.fetchSubPosts(data?.url ?? (id == "home" ? "" : id), sort: sort, after: after, searchText: searchText), let data = response.0 {
      return (Post.initMultiple(datas: data.compactMap { $0.data }, api: RedditAPI.shared, contentWidth: contentWidth), response.1)
    }
    return nil
  }
}

//struct SubredditData: GenericRedditEntityDataType, _DefaultsSerializable {
//
//}

struct SubredditData: Codable, GenericRedditEntityDataType, Defaults.Serializable, Identifiable {
  var user_flair_background_color: String? = nil
  var submit_text_html: String? = nil
  var restrict_posting: Bool? = nil
  var user_is_banned: Bool? = nil
  var free_form_reports: Bool? = nil
  var wiki_enabled: Bool? = nil
  var user_is_muted: Bool? = nil
  var user_can_flair_in_sr: Bool? = nil
  var display_name: String? = nil
  var header_img: String? = nil
  var title: String? = nil
  var allow_galleries: Bool? = nil
  var icon_size: [Int]? = nil
  var primary_color: String? = nil
  var active_user_count: Int? = nil
  var icon_img: String? = nil
  var display_name_prefixed: String? = nil
  var accounts_active: Int? = nil
  var public_traffic: Bool? = nil
  var subscribers: Int? = nil
  var name: String
  var quarantine: Bool? = nil
  var hide_ads: Bool? = nil
  var prediction_leaderboard_entry_type: String? = nil
  var emojis_enabled: Bool? = nil
  var advertiser_category: String? = nil
  var public_description: String
  var comment_score_hide_mins: Int? = nil
  var allow_predictions: Bool? = nil
  var user_has_favorited: Bool? = nil
  var user_flair_template_id: String? = nil
  var community_icon: String? = nil
  var banner_background_image: String? = nil
  var original_content_tag_enabled: Bool? = nil
  var community_reviewed: Bool? = nil
  var over18: Bool? = nil
  var submit_text: String? = nil
  var description_html: String? = nil
  var spoilers_enabled: Bool? = nil
  var allow_talks: Bool? = nil
  var is_enrolled_in_new_modmail: Bool? = nil
  var key_color: String? = nil
  var can_assign_user_flair: Bool? = nil
  var created: Double? = nil
  var show_media_preview: Bool? = nil
  var user_is_subscriber: Bool? = nil
  var allow_videogifs: Bool? = nil
  var should_archive_posts: Bool? = nil
  var user_flair_type: String? = nil
  var allow_polls: Bool? = nil
  var public_description_html: String? = nil
  var allow_videos: Bool? = nil
  var banner_img: String? = nil
  var user_flair_text: String? = nil
  var banner_background_color: String? = nil
  var show_media: Bool? = nil
  var id: String
  var user_is_moderator: Bool? = nil
  var description: String? = nil
  var is_chat_post_feature_enabled: Bool? = nil
  var submit_link_label: String? = nil
  var user_flair_text_color: String? = nil
  var restrict_commenting: Bool? = nil
  var user_flair_css_class: String? = nil
  var allow_images: Bool? = nil
  var url: String
  var created_utc: Double? = nil
  var user_is_contributor: Bool? = nil
  var winstonFlairs: [Flair]? = nil
  //  let comment_contribution_settings: CommentContributionSettings
  //  let header_size: [Int]?
  //  let user_flair_position: String?
  //  let all_original_content: Bool?
  //  let has_menu_widget: Bool?
  //  let wls: Int?
  //  let submission_type: String?
  //  let allowed_media_in_comments: [String]
  //  let collapse_deleted_comments: Bool?
  //  let emojis_custom_size: [Int]?
  //  let is_crosspostable_subreddit: Bool?
  //  let notification_level: String?
  //  let should_show_media_in_comments_setting: Bool?
  //  let can_assign_link_flair: Bool?
  //  let accounts_active_is_fuzzed: Bool?
  //  let allow_prediction_contributors: Bool?
  //  let submit_text_label: String?
  //  let link_flair_position: String?
  //  let user_sr_flair_enabled: Bool?
  //  let user_flair_enabled_in_sr: Bool?
  //  let allow_chat_post_creation: Bool?
  //  let allow_discovery: Bool?
  //  let accept_followers: Bool?
  //  let user_sr_theme_enabled: Bool?
  //  let link_flair_enabled: Bool?
  //  let disable_contributor_requests: Bool?
  let subreddit_type: String?
  //  let suggested_comment_sort: String?
  //  let over18: Bool?
  //  let header_title: String?
  //  let lang: String?
  //  let whitelist_status: String?
  //  let banner_size: [Int]?
  //  let mobile_banner_image: String?
  //  let allow_predictions_tournament: Bool?
  
  var subredditIconKit: SubredditIconKit {
    let communityIconArr = community_icon?.split(separator: "?") ?? []
    let iconRaw = icon_img == "" || icon_img == nil ? communityIconArr.count > 0 ? String(communityIconArr[0]) : "" : icon_img
    let name = display_name ?? ""
    let iconURLStr = iconRaw == "" ? nil : iconRaw
    let color = firstNonEmptyString(key_color, primary_color, "#828282") ?? ""
    
    return SubredditIconKit(url: iconURLStr, initialLetter: String((name).prefix(1)).uppercased(), color: String((firstNonEmptyString(color, "#828282") ?? "").dropFirst(1)))
  }
  
  
  enum CodingKeys: String, CodingKey {
    case user_flair_background_color, submit_text_html, restrict_posting, user_is_banned, free_form_reports, wiki_enabled, user_is_muted, user_can_flair_in_sr, display_name, header_img, title, allow_galleries, icon_size, primary_color, active_user_count, icon_img, display_name_prefixed, accounts_active, public_traffic, subscribers, name, quarantine, hide_ads, prediction_leaderboard_entry_type, emojis_enabled, advertiser_category, public_description, comment_score_hide_mins, allow_predictions, user_has_favorited, user_flair_template_id, community_icon, banner_background_image, original_content_tag_enabled, community_reviewed, submit_text, description_html, spoilers_enabled, allow_talks, is_enrolled_in_new_modmail, key_color, can_assign_user_flair, created, show_media_preview, user_is_subscriber, allow_videogifs, should_archive_posts, user_flair_type, allow_polls, public_description_html, allow_videos, banner_img, user_flair_text, banner_background_color, show_media, id, user_is_moderator, description, is_chat_post_feature_enabled, submit_link_label, user_flair_text_color, restrict_commenting, user_flair_css_class, allow_images, url, created_utc, user_is_contributor, winstonFlairs, subreddit_type, over18
  }
  
  
  init(entity: CachedSub) {
    self.user_flair_background_color = nil
    self.submit_text_html = nil
    self.restrict_posting = nil
    self.user_is_banned = nil
    self.free_form_reports = nil
    self.wiki_enabled = nil
    self.user_is_muted = nil
    self.user_can_flair_in_sr = nil
    self.display_name = nil
    self.header_img = nil
    self.title = nil
    self.allow_galleries = nil
    self.icon_size = nil
    self.primary_color = nil
    self.active_user_count = nil
    self.icon_img = nil
    self.display_name_prefixed = nil
    self.accounts_active = nil
    self.public_traffic = nil
    self.subscribers = nil
    self.quarantine = nil
    self.hide_ads = nil
    self.prediction_leaderboard_entry_type = nil
    self.emojis_enabled = nil
    self.advertiser_category = nil
    self.comment_score_hide_mins = nil
    self.allow_predictions = nil
    self.user_has_favorited = nil
    self.user_flair_template_id = nil
    self.community_icon = nil
    self.banner_background_image = nil
    self.original_content_tag_enabled = nil
    self.community_reviewed = nil
    self.over18 = nil
    self.submit_text = nil
    self.description_html = nil
    self.spoilers_enabled = nil
    self.allow_talks = nil
    self.is_enrolled_in_new_modmail = nil
    self.key_color = nil
    self.can_assign_user_flair = nil
    self.created = nil
    self.show_media_preview = nil
    self.user_is_subscriber = nil
    self.allow_videogifs = nil
    self.should_archive_posts = nil
    self.user_flair_type = nil
    self.allow_polls = nil
    self.public_description = ""
    self.public_description_html = nil
    self.allow_videos = nil
    self.banner_img = nil
    self.user_flair_text = nil
    self.banner_background_color = nil
    self.show_media = nil
    self.user_is_moderator = nil
    self.description = nil
    self.is_chat_post_feature_enabled = nil
    self.submit_link_label = nil
    self.user_flair_text_color = nil
    self.restrict_commenting = nil
    self.user_flair_css_class = nil
    self.allow_images = nil
    self.subreddit_type = "public"
    self.created_utc = nil
    self.user_is_contributor = nil
    self.winstonFlairs = nil
    self.title = nil
    
    
    let x = entity
    self.allow_galleries = x.allow_galleries
    self.allow_images = x.allow_images
    self.allow_videos = x.allow_videos
    self.over18 = x.over18
    self.restrict_commenting = x.restrict_commenting
    self.user_has_favorited = x.user_has_favorited
    self.user_is_banned = x.user_is_banned
    self.user_is_moderator = x.user_is_moderator
    self.user_is_subscriber = x.user_is_subscriber
    self.banner_background_color = x.banner_background_color
    self.banner_background_image = x.banner_background_image
    self.banner_img = x.banner_img
    self.community_icon = x.community_icon
    self.display_name = x.display_name
    self.header_img = x.header_img
    self.icon_img = x.icon_img
    self.key_color = x.key_color
    self.name = x.name ?? ""
    self.primary_color = x.primary_color
    self.title = x.title
    self.url = x.url ?? ""
    self.user_flair_background_color = x.user_flair_background_color
    self.id = x.uuid ?? UUID().uuidString
    self.subscribers = Int(x.subscribers)
  }
  
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let id: String
    if let idValue = try? container.decode(String.self, forKey: .id) {
      id = idValue
    } else if let nameValue = try? container.decode(String.self, forKey: .name) {
      id = nameValue
    } else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: decoder.codingPath,
              debugDescription: "Unable to decode identification.")
      )
      
    }
    
    self.id = id
    
    self.user_flair_background_color = try container.decodeIfPresent(String.self, forKey: .user_flair_background_color)
    self.submit_text_html = try container.decodeIfPresent(String.self, forKey: .submit_text_html)
    self.restrict_posting = try container.decodeIfPresent(Bool.self, forKey: .restrict_posting)
    self.user_is_banned = try container.decodeIfPresent(Bool.self, forKey: .user_is_banned)
    self.subreddit_type = try container.decodeIfPresent(String.self, forKey: .subreddit_type)
    self.free_form_reports = try container.decodeIfPresent(Bool.self, forKey: .free_form_reports)
    self.wiki_enabled = try container.decodeIfPresent(Bool.self, forKey: .wiki_enabled)
    self.user_is_muted = try container.decodeIfPresent(Bool.self, forKey: .user_is_muted)
    self.user_can_flair_in_sr = try container.decodeIfPresent(Bool.self, forKey: .user_can_flair_in_sr)
    self.display_name = try container.decodeIfPresent(String.self, forKey: .display_name)
    self.header_img = try container.decodeIfPresent(String.self, forKey: .header_img)
    self.title = try container.decodeIfPresent(String.self, forKey: .title)
    self.allow_galleries = try container.decodeIfPresent(Bool.self, forKey: .allow_galleries)
    self.icon_size = try container.decodeIfPresent([Int].self, forKey: .icon_size)
    self.primary_color = try container.decodeIfPresent(String.self, forKey: .primary_color)
    self.active_user_count = try container.decodeIfPresent(Int.self, forKey: .active_user_count)
    self.icon_img = try container.decodeIfPresent(String.self, forKey: .icon_img)
    self.display_name_prefixed = try container.decodeIfPresent(String.self, forKey: .display_name_prefixed)
    self.accounts_active = try container.decodeIfPresent(Int.self, forKey: .accounts_active)
    self.public_traffic = try container.decodeIfPresent(Bool.self, forKey: .public_traffic)
    self.subscribers = try container.decodeIfPresent(Int.self, forKey: .subscribers)
    self.name = try container.decode(String.self, forKey: .name)
    self.quarantine = try container.decodeIfPresent(Bool.self, forKey: .quarantine)
    self.hide_ads = try container.decodeIfPresent(Bool.self, forKey: .hide_ads)
    self.prediction_leaderboard_entry_type = try container.decodeIfPresent(String.self, forKey: .prediction_leaderboard_entry_type)
    self.emojis_enabled = try container.decodeIfPresent(Bool.self, forKey: .emojis_enabled)
    self.advertiser_category = try container.decodeIfPresent(String.self, forKey: .advertiser_category)
    self.public_description = try container.decode(String.self, forKey: .public_description)
    self.comment_score_hide_mins = try container.decodeIfPresent(Int.self, forKey: .comment_score_hide_mins)
    self.allow_predictions = try container.decodeIfPresent(Bool.self, forKey: .allow_predictions)
    self.user_has_favorited = try container.decodeIfPresent(Bool.self, forKey: .user_has_favorited)
    self.user_flair_template_id = try container.decodeIfPresent(String.self, forKey: .user_flair_template_id)
    self.community_icon = try container.decodeIfPresent(String.self, forKey: .community_icon)
    self.banner_background_image = try container.decodeIfPresent(String.self, forKey: .banner_background_image)
    self.original_content_tag_enabled = try container.decodeIfPresent(Bool.self, forKey: .original_content_tag_enabled)
    self.community_reviewed = try container.decodeIfPresent(Bool.self, forKey: .community_reviewed)
    self.submit_text = try container.decodeIfPresent(String.self, forKey: .submit_text)
    self.description_html = try container.decodeIfPresent(String.self, forKey: .description_html)
    self.spoilers_enabled = try container.decodeIfPresent(Bool.self, forKey: .spoilers_enabled)
    self.allow_talks = try container.decodeIfPresent(Bool.self, forKey: .allow_talks)
    self.is_enrolled_in_new_modmail = try container.decodeIfPresent(Bool.self, forKey: .is_enrolled_in_new_modmail)
    self.key_color = try container.decodeIfPresent(String.self, forKey: .key_color)
    self.can_assign_user_flair = try container.decodeIfPresent(Bool.self, forKey: .can_assign_user_flair)
    self.created = try container.decodeIfPresent(Double.self, forKey: .created)
    self.show_media_preview = try container.decodeIfPresent(Bool.self, forKey: .show_media_preview)
    self.user_is_subscriber = try container.decodeIfPresent(Bool.self, forKey: .user_is_subscriber)
    self.allow_videogifs = try container.decodeIfPresent(Bool.self, forKey: .allow_videogifs)
    self.should_archive_posts = try container.decodeIfPresent(Bool.self, forKey: .should_archive_posts)
    self.user_flair_type = try container.decodeIfPresent(String.self, forKey: .user_flair_type)
    self.allow_polls = try container.decodeIfPresent(Bool.self, forKey: .allow_polls)
    self.public_description_html = try container.decodeIfPresent(String.self, forKey: .public_description_html)
    self.allow_videos = try container.decodeIfPresent(Bool.self, forKey: .allow_videos)
    self.banner_img = try container.decodeIfPresent(String.self, forKey: .banner_img)
    self.user_flair_text = try container.decodeIfPresent(String.self, forKey: .user_flair_text)
    self.banner_background_color = try container.decodeIfPresent(String.self, forKey: .banner_background_color)
    self.show_media = try container.decodeIfPresent(Bool.self, forKey: .show_media)
    //  self.id = try container.decodeIfPresent(String.self, forKey: .id)
    self.user_is_moderator = try container.decodeIfPresent(Bool.self, forKey: .user_is_moderator)
    self.description = try container.decodeIfPresent(String.self, forKey: .description)
    self.is_chat_post_feature_enabled = try container.decodeIfPresent(Bool.self, forKey: .is_chat_post_feature_enabled)
    self.submit_link_label = try container.decodeIfPresent(String.self, forKey: .submit_link_label)
    self.user_flair_text_color = try container.decodeIfPresent(String.self, forKey: .user_flair_text_color)
    self.restrict_commenting = try container.decodeIfPresent(Bool.self, forKey: .restrict_commenting)
    self.user_flair_css_class = try container.decodeIfPresent(String.self, forKey: .user_flair_css_class)
    self.allow_images = try container.decodeIfPresent(Bool.self, forKey: .allow_images)
    self.url = try container.decode(String.self, forKey: .url)
    self.created_utc = try container.decodeIfPresent(Double.self, forKey: .created_utc)
    self.user_is_contributor = try container.decodeIfPresent(Bool.self, forKey: .user_is_contributor)
    self.winstonFlairs = try container.decodeIfPresent([Flair].self, forKey: .winstonFlairs)
    self.over18 = try container.decodeIfPresent(Bool.self, forKey: .over18)
  }
}

struct CommentContributionSettings: Codable, Hashable {
  let allowed_media_types: [String]?
}

struct SubListingSort: Codable, Identifiable {
  var icon: String
  var value: String
  var id: String {
    value
  }
}

enum SubListingSortOption: Codable, Identifiable, Defaults.Serializable, Hashable {
  var id: String {
    self.rawVal.id
  }
  
  case best
  case hot
  case new
  case controversial
  case top(TopListingSortOption)
  
  enum TopListingSortOption: String, Codable, CaseIterable, Hashable {
    case hour
    case day
    case week
    case month
    case year
    case all
  
    
    var icon: String {
      switch self {
      case .hour: return "clock"
      case .day: return "sun.max"
      case .week: return "clock.arrow.2.circlepath"
      case .month: return "calendar"
      case .year: return "globe.americas.fill"
      case .all: return "arrow.up.circle.badge.clock"
      }
    }
  }
  
  var rawVal: SubListingSort {
    switch self {
    case .best: return SubListingSort(icon: "trophy", value: "best")
    case .controversial: return SubListingSort(icon: "figure.fencing", value: "controversial")
    case .hot: return SubListingSort(icon: "flame", value: "hot")
    case .new: return SubListingSort(icon: "newspaper", value: "new")
    case .top(let subOption):
      if subOption == .all {
        return SubListingSort(icon: subOption.icon, value: "top")
      } else {
        return SubListingSort(icon: subOption.icon, value: "top/\(subOption.rawValue)")
      }
    }
  }
}

extension SubListingSortOption: CaseIterable {
  static var allCases: [SubListingSortOption] {
    return [.best, .hot, .new, .controversial, .top(.all)]
  }
}
