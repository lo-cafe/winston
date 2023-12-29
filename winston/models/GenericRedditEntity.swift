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

class GenericRedditEntity<T: GenericRedditEntityDataType, B: Hashable>: Identifiable, Hashable, ObservableObject, Observable, Codable,  _DefaultsSerializable {
  func hash(into hasher: inout Hasher) {
//    hasher.combine(data)
//    hasher.combine(childrenWinston.data)
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
  
  @Published var data: T? {
    didSet {
      if let newID = data?.id, id != newID {
        self.id =  newID
      }
    }
  }
  
  var selfPrefix: String { "" }
  
  @Published var winstonData: B? = nil
  @Published var _id: String
  var id: String {
    get {
      return self._id + self.kind
    }
    set {
      self._id = newValue
    }
  }
  @Published var loading = false
  @Published var typePrefix: String?
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
  @Published var childrenWinston: ObservableArray<GenericRedditEntity<T, B>> = ObservableArray<GenericRedditEntity<T, B>>(array: [])
  var parentWinston: ObservableArray<GenericRedditEntity<T, B>>?
  
  private func setupWatchers() {
    anyCancellables?.append(childrenWinston.objectWillChange.sink { [weak self] (_) in
        self?.objectWillChange.send()
    })
  }
  
  required init(id: String, typePrefix: String?) {
    self._id = id
    self.typePrefix = typePrefix
//    self.setupWatchers()
  }

  required init(data: T, typePrefix: String?) {
    self.data = data
    self._id = data.id
    self.typePrefix = typePrefix
//    self.setupWatchers()
  }
  
  init(data: T, typePrefix: String?, kind: String? = nil) {
    self.data = data
    self.kind = kind
    self._id = data.id
    self.typePrefix = typePrefix
//    self.setupWatchers()
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

enum RedditEntityType {
  case post(Post)
  case comment(Comment)
  case user(User)
  case subreddit(Subreddit)
}
