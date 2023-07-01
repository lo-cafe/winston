//
//  GenericRedditEntity.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation

protocol GenericRedditEntityDataType: Codable, Hashable {
  var id: String { get }
}

struct GenericRedditEntity<T: GenericRedditEntityDataType>: Identifiable, Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }
  
  static func == (lhs: GenericRedditEntity<T>, rhs: GenericRedditEntity<T>) -> Bool {
    return lhs.data == rhs.data
  }
  
  var data: T? {
    didSet {
      if let id = data?.id {
        self.id = id
      }
    }
  }
  let redditAPI: RedditAPI
  var id: String
  var loading = false
  var typePrefix: String?
  
  init(id: String, api: RedditAPI, typePrefix: String?) {
    self.id = id
    self.redditAPI = api
    self.typePrefix = typePrefix
  }
  
  init(data: T, api: RedditAPI, typePrefix: String?) {
    self.data = data
    self.id = data.id
    self.redditAPI = api
    self.typePrefix = typePrefix
  }
}
