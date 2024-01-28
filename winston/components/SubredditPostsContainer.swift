//
//  SubredditPostsContainer.swift
//  winston
//
//  Created by Igor Marcossi on 29/07/23.
//

import SwiftUI

struct SubredditPostsContainerPayload: Hashable {
  var sub: Subreddit
  var highlightID: String? = nil
}

