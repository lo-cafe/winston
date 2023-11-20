//
//  AvatarTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct AvatarTheme: Codable, Hashable, Equatable {
  enum CodingKeys: String, CodingKey {
    case size, cornerRadius, visible
  }
  var size: CGFloat
  var cornerRadius: CGFloat
  var visible: Bool
  
  init(size: CGFloat, cornerRadius: CGFloat, visible: Bool) {
    self.size = size
    self.cornerRadius = cornerRadius
    self.visible = visible
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encodeIfPresent(cornerRadius, forKey: .cornerRadius)
    try container.encodeIfPresent(visible, forKey: .visible)
  }
  
  init(from decoder: Decoder) throws {
    let t = defaultAvatarTheme
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.size = try container.decodeIfPresent(CGFloat.self, forKey: .size) ?? t.size
    self.cornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .cornerRadius) ?? t.cornerRadius
    self.visible = try container.decodeIfPresent(Bool.self, forKey: .visible) ?? t.visible
  }
}
