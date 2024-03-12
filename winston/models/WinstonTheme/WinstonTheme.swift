//
//  WinstonTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation
import SwiftUI
import Defaults

struct WinstonTheme: Codable, Identifiable, Hashable, Equatable, Defaults.Serializable {
  enum CodingKeys: String, CodingKey {
    case metadata, id, postLinks, posts, comments, lists, general
  }
  
  var metadata: WinstonThemeMeta
  var id: String
  var postLinks: SubPostsListTheme
  var posts: PostTheme
  var comments: CommentsSectionTheme
  var lists: ListsTheme
  var general: GeneralTheme
  
  func save() {
    guard let index = Defaults[.ThemesDefSettings].themesPresets.firstIndex(where: { $0.id == self.id }) else { return }
    Defaults[.ThemesDefSettings].themesPresets[index] = self
  }
  
  func duplicate() -> WinstonTheme {
    var copy = self
    copy.id = UUID().uuidString
    if copy.metadata.name == "Default" { copy.metadata.name = randomWord().capitalized }
    return copy
  }
  
  init(
    metadata: WinstonThemeMeta = WinstonThemeMeta(),
    id: String = UUID().uuidString,
    postLinks: SubPostsListTheme,
    posts: PostTheme,
    comments: CommentsSectionTheme,
    lists: ListsTheme,
    general: GeneralTheme
  ) {
    self.metadata = metadata
    self.id = id
    self.postLinks = postLinks
    self.posts = posts
    self.comments = comments
    self.lists = lists
    self.general = general
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(metadata, forKey: .metadata)
    try container.encodeIfPresent(id, forKey: .id)
    try container.encodeIfPresent(postLinks, forKey: .postLinks)
    try container.encodeIfPresent(posts, forKey: .posts)
    try container.encodeIfPresent(comments, forKey: .comments)
    try container.encodeIfPresent(lists, forKey: .lists)
    try container.encodeIfPresent(general, forKey: .general)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.metadata = try container.decode(WinstonThemeMeta.self, forKey: .metadata)
    self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
    self.postLinks = try container.decodeIfPresent(SubPostsListTheme.self, forKey: .postLinks) ?? defaultTheme.postLinks
    self.posts = try container.decodeIfPresent(PostTheme.self, forKey: .posts) ?? defaultTheme.posts
    self.comments = try container.decodeIfPresent(CommentsSectionTheme.self, forKey: .comments) ?? defaultTheme.comments
    self.lists = try container.decodeIfPresent(ListsTheme.self, forKey: .lists) ?? defaultTheme.lists
    self.general = try container.decodeIfPresent(GeneralTheme.self, forKey: .general) ?? defaultTheme.general
  }
}
