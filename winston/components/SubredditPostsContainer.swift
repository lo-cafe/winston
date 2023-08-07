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

struct SubredditPostsContainer: View {
  @StateObject var sub: Subreddit
  var highlightID: String?
  var body: some View {
    SubredditPosts(subreddit: sub)
  }
}
