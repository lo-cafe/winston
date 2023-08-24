//
//  Multi.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Defaults

typealias Multi = GenericRedditEntity<MultiData>

extension Multi {
  static var prefix = "LabeledMulti"
  convenience init(data: T, api: RedditAPI) {
    self.init(data: data, api: api, typePrefix: "\(Post.prefix)_")
  }
  
  convenience init(id: String, api: RedditAPI) {
    self.init(id: id, api: api, typePrefix: "\(Post.prefix)_")
  }
  
  func fetchData() async -> Bool? {
//    if let data = await redditAPI.fetchMultiInfo(id) {
//      
//    }
    return nil
  }
  
  func fetchPosts(sort: SubListingSortOption = .best, after: String? = nil) async -> ([Post]?, String?)? {
    if let data = data {
      if let response = await redditAPI.fetchMultiPosts(path: data.path, sort: sort, after: after), let data = response.0 {
        return (Post.initMultiple(datas: data.compactMap { $0.data }, api: redditAPI), response.1)
      }
    }
    return nil
  }
  
  func delete() async -> Bool? {
    if let data = data {
      return await redditAPI.deleteMulti(data.path)
    }
    return nil
  }
}


struct MultiData: GenericRedditEntityDataType, Defaults.Serializable {
  let can_edit: Bool?
  let display_name, name: String
  let description_html: String?
  let num_subscribers: Int?
  let copied_from: String?
  let icon_url: String?
  var subreddits: [MultiSub]?
  let created_utc, created: Double?
  let visibility: MultiVisibility?
  let over_18: Bool?
  let path: String
  let owner, key_color: String?
  let is_subscriber, is_favorited: Bool?
  let owner_id, description_md: String?
  var id: String { path }
}


struct MultiSub: Codable, Hashable, Identifiable {
  let name: String
  var id: String { name }
  var data: SubredditData?
}

enum MultiVisibility: String, CaseIterable, Codable {
  case priv = "private"
  case pub = "public"
  case hid = "hidden"
}
