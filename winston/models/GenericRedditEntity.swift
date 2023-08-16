//
//  GenericRedditEntity.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Combine

protocol GenericRedditEntityDataType: Codable, Hashable, Identifiable {
  var id: String { get }
}

class GenericRedditEntity<T: GenericRedditEntityDataType>: Identifiable, Hashable, ObservableObject, Codable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
    hasher.combine(childrenWinston.data)
  }
  
  static func placeholder() -> GenericRedditEntity<T> {
    GenericRedditEntity<T>(id: "none", api: RedditAPI(), typePrefix: nil)
  }
  
  static func == (lhs: GenericRedditEntity<T>, rhs: GenericRedditEntity<T>) -> Bool {
    return lhs.id == rhs.id && lhs.kind == rhs.kind && lhs.data == rhs.data && lhs.data?.id == rhs.data?.id
  }
  
  @Published var data: T? {
    didSet {
      if let newID = data?.id {
        self.id =  kind == "more" ? "\(newID)-more" : newID
      }
    }
  }
  @Published var id: String
  @Published var loading = false
  @Published var typePrefix: String?
  var kind: String?
  
  enum CodingKeys: CodingKey {
    case id, loading, typePrefix, kind, data, childrenWinstonData
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
  @Published var childrenWinston: ObservableArray<GenericRedditEntity<T>> = ObservableArray<GenericRedditEntity<T>>(array: [])
  var parentWinston: ObservableArray<GenericRedditEntity<T>>?
  
  required init(id: String, api: RedditAPI, typePrefix: String?) {
    self.id = kind == "more" ? "\(id)-more" : id
    self.redditAPI = api
    self.typePrefix = typePrefix
    anyCancellable = childrenWinston.objectWillChange.sink { [weak self] (_) in
        self?.objectWillChange.send()
    }
  }

  required init(data: T, api: RedditAPI, typePrefix: String?) {
    self.data = data
    self.id = data.id
    self.redditAPI = api
    self.typePrefix = typePrefix
    anyCancellable = childrenWinston.objectWillChange.sink { [weak self] (_) in
        self?.objectWillChange.send()
    }
  }
  
  init(data: T, api: RedditAPI, typePrefix: String?, kind: String? = nil) {
    self.data = data
    self.kind = kind
    self.id = kind == "more" ? "\(data.id)-more" : data.id
    self.redditAPI = api
    self.typePrefix = typePrefix
    anyCancellable = childrenWinston.objectWillChange.sink { [weak self] (_) in
        self?.objectWillChange.send()
    }
  }
  
  func duplicate() -> GenericRedditEntity<T> {
    let copy = GenericRedditEntity<T>(id: id, api: redditAPI, typePrefix: typePrefix)
    copy.data = data
    copy.kind = kind
    copy.childrenWinston = childrenWinston
    return copy
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
