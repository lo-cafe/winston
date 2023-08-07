//
//  PostsInBoxView.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import SwiftUI
import Defaults
import Combine

struct PostsInBoxView: View {
  var someOpened: Bool
  @EnvironmentObject private var redditAPI: RedditAPI
  @Default(.postsInBox) private var postsInBox
  
  var body: some View {
    if postsInBox.count > 0 {
      Section("Posts Box") {
        ScrollView(.horizontal) {
          HStack(spacing: 12) {
            ForEach(postsInBox, id: \.self.id) { post in
              PostInBoxLink(post: post)
                .animation(spring, value: postsInBox)
            }
          }
        }
        .id("quickPosts")
        .onChange(of: someOpened) { newValue in if !newValue { Task { await updatePostsInBox(redditAPI) } } }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      }
    }
  }
}
