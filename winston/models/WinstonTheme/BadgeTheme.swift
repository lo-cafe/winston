//
//  BadgeTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation

struct BadgeTheme: Codable, Hashable {
  var avatar: AvatarTheme
  var authorText: ThemeText
  var statsText: ThemeText
  var spacing: CGFloat
}
