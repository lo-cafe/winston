//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI
import Combine

class Router: ObservableObject, Hashable, Equatable, Codable {
  let id: String
  
  var firstSelected: NavDest? {
    get { fullPath.isEmpty ? nil : fullPath[0] }
    set {
      if let newValue = newValue {
        if fullPath.count == 0 { fullPath.append(newValue) } else { fullPath[0] = newValue } } else { fullPath = [] }
    }
  }
  @Published var fullPath: [NavDest] = []
  var path: [NavDest] {
    get { Array(self.fullPath.dropFirst()) }
    set {
      if fullPath.isEmpty { self.fullPath = newValue } else { self.fullPath = [fullPath[0]] + newValue }
    }
  }
  @Published private(set) var isAtRoot = false
  
  private var cancellables = Set<AnyCancellable>()
  
  init(id: String) {
    self.id = id
    $fullPath.map { $0.isEmpty }.assign(to: \.isAtRoot, on: self).store(in: &cancellables)
  }
  
  func goBack() { _ = withAnimation { self.fullPath.removeLast() } }
  func resetNavPath() { withAnimation { self.fullPath.removeAll() } }
  func navigateTo(_ dest: NavDest, _ reset: Bool = false) { withAnimation { self.path = reset ? [dest] : self.path + [dest] } }
  
  enum NavDest: Hashable, Codable, Identifiable {
    var id: String {
      switch self {
      case .reddit(let reddit): return reddit.id
      case .setting(let setting): return setting.id
      }
    }
    case reddit(Reddit)
    case setting(Setting)
    
    enum Reddit: Hashable, Codable, Identifiable {
      var id: String {
        switch self {
        case .post(let post): return post.id
        case .postHighlighted(let post, _): return post.id
        case .subFeed(let subreddit): return subreddit.id
        case .subInfo(let subreddit): return subreddit.id
        case .multiFeed(let multi): return multi.id
        case .multiInfo(let multi): return multi.id
        case .user(let user): return user.id
        }
      }
      case post(Post)
      case postHighlighted(Post, String)
      case subFeed(Subreddit)
      case subInfo(Subreddit)
      case multiFeed(Multi)
      case multiInfo(Multi)
      case user(User)
    }
    enum Setting: String, Hashable, Codable, Identifiable {
      var id: String { self.rawValue }
      case behavior, appearance, credentials, about, commentSwipe, postSwipe, accessibility, faq, general, themes, filteredSubreddits, appIcon, themeStore
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
