//
//  cache.swift
//  winston
//
//  Created by Igor Marcossi on 20/09/23.
//

import Foundation
import YouTubePlayerKit
import NukeUI
import UIKit

// WE SHOULD AVOID USING THIS TYPE OF CACHE
// Don't create any more caches in this format,
// there's no reason for the cache to be managed by us manually this way.

class Caches {
  static let postsAttrStr = BaseCache<AttributedString>(cacheLimit: 100)
  static let videos = BaseCache<SharedVideo>(cacheLimit: 50)
  static let streamable = BaseCache<StreamableCached>(cacheLimit: 100)
}
