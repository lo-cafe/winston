//
//  UserData.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Foundation

typealias User = GenericRedditEntity<UserData, AnyHashable>

extension User {
  static var prefix = "t2"
  var selfPrefix: String { Self.prefix }
  
  convenience init(data: T) {
    self.init(data: data, typePrefix: "\(User.prefix)_")
  }
  convenience init(id: String) {
    self.init(id: id, typePrefix: "\(User.prefix)_")
  }
  
  func refetchOverview(_ dataTypeFilter: String? = nil, _ after: String? = nil) async -> ([Either<Post, Comment>]?, String?)? {
    let name = data?.name ?? data?.id ?? id
    if let overviewDataResult = await RedditAPI.shared.fetchUserOverview(name, dataTypeFilter, after), let overviewData = overviewDataResult.0 {
      await MainActor.run {
        self.loading = false
      }
      
      return (overviewData.map {
        switch $0 {
        case .first(let postData):
          return .first(Post(data: postData))
        case .second(let commentData):
          return .second(Comment(data: commentData))
        }
      }, overviewDataResult.1)
    }
    return nil
  }
  
  func refetchUser() async {
    await MainActor.run {
      self.loading = true
    }
    let userName = data?.name ?? id
    if let data = (await RedditAPI.shared.fetchUser(userName)) {
      await MainActor.run {
        self.data = data
      }
    }
    await MainActor.run {
      self.loading = false
    }
  }
  
  func fetchItself() {
    Task(priority: .background) {
      if let data = await RedditAPI.shared.fetchUser(id) {
        await MainActor.run { withAnimation {
          self.data = data
        } }
      }
    }
  }
}

struct UserData: GenericRedditEntityDataType {
  var has_paypal_subscription: Bool?
  var has_stripe_subscription: Bool?
  var in_beta: Bool?
  var oauth_client_id: String?
  var has_subscribed_to_premium: Bool?
  var pref_show_twitter: Bool?
  var pref_top_karma_subreddits: Bool?
  var pref_show_snoovatar: Bool?
  var id: String
  let icon_img: String?
  var has_verified_email: Bool?
  var has_android_subscription: Bool?
  var is_suspended: Bool?
  var is_friend: Bool?
  var has_visited_new_profile: Bool?
  var can_edit_name: Bool?
  var in_chat: Bool?
  var link_karma: Int?
  var total_karma: Int?
  var comment_karma: Int?
  var awardee_karma: Int?
  var awarder_karma: Int?
  var gold_expiration: Double?
  var has_ios_subscription: Bool?
  var created_utc: Double?
  var created: Double?
  var pref_show_presence: Bool?
  var snoovatar_img: String?
  var in_redesign_beta: Bool?
  var is_employee: Bool?
  var name: String
  var pref_autoplay: Bool?
  var pref_no_profanity: Bool?
  var has_external_account: Bool?
  var is_sponsor: Bool?
  var has_mail: Bool?
  var has_mod_mail: Bool?
  var is_gold: Bool?
  var is_mod: Bool?
  var pref_show_trending: Bool?
  var features: Features?
  let subreddit: UserDataSubreddit?
}

struct Features: Codable, Hashable {
  var modmail_harassment_filter: Bool?
  var mod_service_mute_writes: Bool?
  var mod_service_mute_reads: Bool?
  var images_in_comments: Bool?
  var awards_on_streams: Bool?
  var live_happening_now: Bool?
  var chat: Bool?
  var mod_awards: Bool?
  var mweb_xpromo_revamp_v2: Mweb_Xpromo_revamp_v2?
  var mweb_link_tab: Mweb_link_tab?
  var mweb_xpromo_revamp_v3: Mweb_xpromo_revamp_v3?
  var mweb_sharing_web_share_api: Mweb_sharing_web_share_api?
}

struct Mweb_Xpromo_revamp_v2: Codable, Hashable {
  var owner: String
  var variant: String
  var experiment_id: Int
}

struct Mweb_xpromo_revamp_v3: Codable, Hashable {
  var owner: String
  var variant: String
  var experiment_id: Int
}

struct Mweb_link_tab: Codable, Hashable {
  var owner: String
  var variant: String
  var experiment_id: Int
}

struct Mweb_sharing_web_share_api: Codable, Hashable {
  var owner: String?
  var variant: String?
  var experiment_id: Int?
}

struct UserDataSubreddit: Codable, Hashable {
  let default_set: Bool?
  let user_is_contributor: Bool?
  let banner_img: String?
  let restrict_posting: Bool?
  let user_is_banned: Bool?
  let free_form_reports: Bool?
  let community_icon: String?
  let show_media: Bool?
  let icon_color: String?
  let user_is_muted: Bool?
  let display_name: String?
  let header_img: String?
  let title: String?
  let coins: Int?
  let previous_names: [String]?
  let over_18: Bool?
  let icon_size: [Int]?
  let primary_color: String?
  let icon_img: String?
  let description: String?
  let allowed_media_in_comments: [String]?
  let submit_link_label: String?
  let header_size: [Int]?
  let restrict_commenting: Bool?
  let subscribers: Int?
  let submit_text_label: String?
  let is_default_icon: Bool?
  let link_flair_position: String?
  let display_name_prefixed: String?
  let key_color: String?
  let name: String?
  let is_default_banner: Bool?
  let url: String?
  let quarantine: Bool?
  let banner_size: [Int]?
  let user_is_moderator: Bool?
  let accept_followers: Bool?
  let public_description: String?
  let link_flair_enabled: Bool?
  let disable_contributor_requests: Bool?
  let subreddit_type: String?
  let user_is_subscriber: Bool?
}


