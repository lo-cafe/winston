//
//  Multi.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Defaults
import UIKit

typealias Multi = GenericRedditEntity<MultiData, AnyHashable>

extension Multi {
  static var prefix = "LabeledMulti"
  var selfPrefix: String { Self.prefix }
  convenience init(data: T, api: RedditAPI) {
    self.init(data: data, api: api, typePrefix: "\(Post.prefix)_")
  }
  
  convenience init(id: String, api: RedditAPI) {
    self.init(id: id, api: api, typePrefix: "\(Post.prefix)_")
  }
  
  func fetchData() async -> Bool? {
//    if let data = await RedditAPI.shared.fetchMultiInfo(id) {
//      
//    }
    return nil
  }
  
  func fetchPosts(sort: SubListingSortOption = .best, after: String? = nil, contentWidth: CGFloat = UIScreen.screenWidth) async -> ([Post]?, String?)? {
    if let data = data {
      if let response = await RedditAPI.shared.fetchMultiPosts(path: data.path, sort: sort, after: after), let data = response.0 {
        return (Post.initMultiple(datas: data.compactMap { $0.data }, api: RedditAPI.shared, fetchSubs: true, contentWidth: contentWidth), response.1)
      }
    }
    return nil
  }
  
  func delete() async -> Bool? {
    if let data = data {
      return await RedditAPI.shared.deleteMulti(data.path)
    }
    return nil
  }
}


struct MultiData: GenericRedditEntityDataType, Defaults.Serializable {
  var can_edit: Bool? = nil
  let display_name, name: String
  var description_html: String? = nil
  var num_subscribers: Int? = nil
  var copied_from: String? = nil
  var icon_url: String? = nil
  var subreddits: [MultiSub]? = nil
  var created_utc: Double? = nil
  var created: Double? = nil
  let visibility: MultiVisibility?
  var over_18: Bool? = nil
  let path: String
  var key_color: String? = nil
  var owner: String? = nil
  var is_subscriber: Bool? = nil
  var is_favorited: Bool? = nil
  var description_md: String? = nil
  var owner_id: String? = nil
  var id: String { path }
  
  init(entity: CachedMulti) {
//    self.can_edit = entity.can_edit
    self.display_name = entity.display_name ?? ""
    self.name = entity.name ?? ""
    self.description_html = nil
    self.num_subscribers = nil
    self.copied_from = nil
    self.icon_url = entity.icon_url
    self.subreddits = entity.subsArray.map { x in
      let data = SubredditData(entity: x)
      return MultiSub(name: data.name, data: data)
    }
    self.created_utc = nil
    self.visibility = nil
    self.over_18 = entity.over_18
    self.path = entity.path ?? ""
    self.owner = nil
    self.key_color = entity.key_color
    self.is_subscriber = nil
    self.is_favorited = nil
    self.owner_id = nil
    self.description_md = nil
//    self.id = entity.uuid
  }
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
