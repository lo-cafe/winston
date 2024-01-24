//
//  GenericRedditEntity.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Combine
import Defaults
import SwiftUI

protocol GenericRedditEntityDataType: Codable, Hashable, Identifiable {
  var id: String { get }
}

@Observable
class GenericRedditEntity<T: GenericRedditEntityDataType, B: Hashable>: Identifiable, Hashable, ObservableObject, Observable, Codable,  _DefaultsSerializable {
  func hash(into hasher: inout Hasher) {
//    hasher.combine(data)
//    hasher.combine(childrenWinston)
    hasher.combine(id)
    hasher.combine(typePrefix)
//    hasher.combine(data)
  }
  
  static func placeholder() -> GenericRedditEntity<T, B> {
    GenericRedditEntity<T, B>(id: "none", typePrefix: nil)
  }
  
  static func == (lhs: GenericRedditEntity<T, B>, rhs: GenericRedditEntity<T, B>) -> Bool {
    return lhs.id == rhs.id && lhs.kind == rhs.kind && lhs.data?.id == rhs.data?.id
  }
  
  var data: T? {
    didSet {
      if let newID = data?.id, id != newID {
        self.id =  newID
      }
    }
  }
  
  var selfPrefix: String { "" }
  
  var winstonData: B? = nil
  var _id: String
  var id: String {
    get {
      return self._id + self.kind
    }
    set {
      self._id = newValue
    }
  }
  var loading = false
  var typePrefix: String?
  var kind: String?
  
  enum CodingKeys: CodingKey {
    case _id, loading, typePrefix, kind, data, childrenWinstonData
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    _id = try container.decode(String.self, forKey: ._id)
    loading = try container.decode(Bool.self, forKey: .loading)
    typePrefix = try container.decodeIfPresent(String.self, forKey: .typePrefix)
    kind = try container.decodeIfPresent(String.self, forKey: .kind)
    data = try container.decodeIfPresent(T.self, forKey: .data)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(_id, forKey: ._id)
    try container.encode(loading, forKey: .loading)
    try container.encode(typePrefix, forKey: .typePrefix)
    try container.encode(kind, forKey: .kind)
    try container.encode(data, forKey: .data)
  }
  
  let redditAPI: RedditAPI = .shared
  var anyCancellables: [AnyCancellable]? = nil
  var childrenWinston: [GenericRedditEntity<T, B>] = []
  var parentWinston: [GenericRedditEntity<T, B>]?
  
  required init(id: String, typePrefix: String?) {
    self._id = id
    self.typePrefix = typePrefix
  }

  required init(data: T, typePrefix: String?) {
    self.data = data
    self._id = data.id
    self.typePrefix = typePrefix
  }
  
  init(data: T, typePrefix: String?, kind: String? = nil) {
    self.data = data
    self.kind = kind
    self._id = data.id
    self.typePrefix = typePrefix
  }
  
  func duplicate() -> GenericRedditEntity<T, B> {
    let copy = GenericRedditEntity<T, B>(id: id, typePrefix: typePrefix)
    copy.data = data
    copy.kind = kind
    copy.childrenWinston = childrenWinston
    return copy
  }
  
  func fetchItself() {
    Task(priority: .background) {
      if let data = await RedditAPI.shared.fetchInfo(fullnames: ["\(self.selfPrefix)_\(id)"]) {
        await MainActor.run { withAnimation {
          if let data = data as? T { self.data = data }
        } }
      }
    }
  }
}

enum RedditEntityType: Hashable, Equatable, Identifiable {
  case post(Post)
  case subreddit(Subreddit)
  case multi(Multi)
  case comment(Comment)
  case user(User)
  case message(Message)
  
  var id: String {
    switch self {
    case .post(let x): x.id
    case .subreddit(let x): x.id
    case .multi(let x): x.id
    case .comment(let x): x.id
    case .user(let x): x.id
    case .message(let x): x.id
    }
  }
}
