//
//  cache.swift
//  winston
//
//  Created by Igor Marcossi on 20/09/23.
//

import Foundation
import YouTubePlayerKit

class Caches {
  static let ytPlayers = BaseObservableCache<YouTubePlayer>(cacheLimit: 35)
  static let postsAttrStr = BaseCache<AttributedString>(cacheLimit: 100)
}
