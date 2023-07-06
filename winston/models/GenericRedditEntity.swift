//
//  GenericRedditEntity.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Combine

protocol GenericRedditEntityDataType: Codable, Hashable {
  var id: String { get }
}

class GenericRedditEntity<T: GenericRedditEntityDataType>: Identifiable, Hashable, ObservableObject, Codable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }
  
  static func == (lhs: GenericRedditEntity<T>, rhs: GenericRedditEntity<T>) -> Bool {
    return lhs.id == rhs.id
  }
  
  @Published var data: T? {
    didSet {
      if let id = data?.id {
        self.id = id
      }
    }
  }
  @Published var id: String
  @Published var loading = false
  @Published var typePrefix: String?
  var kind: String?
  
  enum CodingKeys: CodingKey {
    case id, loading, typePrefix, kind, data
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    loading = try container.decode(Bool.self, forKey: .loading)
    typePrefix = try container.decodeIfPresent(String.self, forKey: .typePrefix)
    kind = try container.decodeIfPresent(String.self, forKey: .kind)
    data = try container.decodeIfPresent(T.self, forKey: .data)
    self.redditAPI = RedditAPI() // provide a default value
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(loading, forKey: .loading)
    try container.encode(typePrefix, forKey: .typePrefix)
    try container.encode(kind, forKey: .kind)
    try container.encode(data, forKey: .data)
  }
  
  let redditAPI: RedditAPI
  var anyCancellable: AnyCancellable? = nil
  @Published var childrenWinston = ObservableArray<GenericRedditEntity<T>>(array: [])
  
  init(id: String, api: RedditAPI, typePrefix: String?) {
    self.id = id
    self.redditAPI = api
    self.typePrefix = typePrefix
    anyCancellable = childrenWinston.objectWillChange.sink { [weak self] (_) in
        self?.objectWillChange.send()
    }
  }

  init(data: T, api: RedditAPI, typePrefix: String?) {
    self.data = data
    self.id = data.id
    self.redditAPI = api
    self.typePrefix = typePrefix
    anyCancellable = childrenWinston.objectWillChange.sink { [weak self] (_) in
        self?.objectWillChange.send()
    }
  }
}






//class GenericRedditEntity<T: GenericRedditEntityDataType>: Codable, Identifiable, Hashable, ObservableObject {
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(data)
//  }
//
//  static func == (lhs: GenericRedditEntity<T>, rhs: GenericRedditEntity<T>) -> Bool {
////    print(lhs.id, rhs.id, lhs.id == rhs.id)
//    return lhs.id == rhs.id
//  }
//
//  @Published var data: T? {
//    didSet {
//      if let id = data?.id {
//        self.id = id
//      }
//    }
//  }
//  let redditAPI: RedditAPI
//  @Published var id: String
//  @Published var loading = false
//  @Published var typePrefix: String?
//  var kind: String?
//  var anyCancellable: AnyCancellable? = nil
//
//  init(id: String, api: RedditAPI, typePrefix: String?) {
//    self.id = id
//    self.redditAPI = api
//    self.typePrefix = typePrefix
//  }
//
//  init(data: T, api: RedditAPI, typePrefix: String?) {
//    self.data = data
//    self.id = data.id
//    self.redditAPI = api
//    self.typePrefix = typePrefix
//  }
//}
