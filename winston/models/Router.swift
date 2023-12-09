//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI
import Combine
import AnyCodable

class RouterIsRoot: ObservableObject {
  @Published var isRoot = true
}

class Router: ObservableObject, Hashable, Equatable, Codable {
  let id: String
  @Published var firstSelected: NavDest?
  @Published var path: [NavDest] = []
  @Published private(set) var isAtRoot = false

  private var cancellables = Set<AnyCancellable>()

  init(id: String) {
    self.id = id
    Publishers.CombineLatest($firstSelected, $path)
      .map { $0.0 == nil && $0.1.isEmpty }
      .assign(to: \.isAtRoot, on: self)
      .store(in: &cancellables)
  }
  
  func goBack() { self.path.removeLast() }
  func resetNavPath() { self.path.removeAll() }
  func navigateTo(_ dest: NavDest, _ reset: Bool = false) { self.path = reset ? [dest] : self.path + [dest] }
  
  enum NavDest: Hashable, Codable {
    case reddit(Reddit)
    case setting(Setting)
    
    enum Reddit: Hashable, Codable {
      static var post: (Post) -> NavDest = { .reddit(.post($0)) }
      static var postHighlighted: (Post, String) -> NavDest = { .reddit(.postHighlighted($0, $1)) }
      static var subFeed: (Subreddit) -> NavDest = { .reddit(.subFeed($0)) }
      static var subInfo: (Subreddit) -> NavDest = { .reddit(.subInfo($0)) }
      static var multiFeed: (Multi) -> NavDest = { .reddit(.multiFeed($0)) }
      static var multiInfo: (Multi) -> NavDest = { .reddit(.multiInfo($0)) }
      static var user: (User) -> NavDest = { .reddit(.user($0)) }
      
      case post(Post)
      case postHighlighted(Post, String)
      case subFeed(Subreddit)
      case subInfo(Subreddit)
      case multiFeed(Multi)
      case multiInfo(Multi)
      case user(User)
    }
    enum Setting: String, Hashable, Codable {
      case behavior, appearance, credentials, about, commentSwipe, postSwipe, accessibility, faq, general, postFontSettings, themes, filteredSubreddits, appIcon, themeStore
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case id, firstSelected, path
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(firstSelected, forKey: .firstSelected)
    try container.encode(path, forKey: .path)
  }
  
  required init(from decoder: Decoder) throws {
    let t = defaultTheme.comments
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.firstSelected = try container.decodeIfPresent(NavDest.self, forKey: .firstSelected)
    self.path = try container.decode([NavDest].self, forKey: .path)
    self.isAtRoot = self.firstSelected == nil && self.path.count == 0
  }
  
  static func == (lhs: Router, rhs: Router) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(firstSelected)
    hasher.combine(path)
  }
}
