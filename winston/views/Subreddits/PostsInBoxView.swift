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
  @Binding var selectedSub: FirstSelectable?
  @Default(.postsInBox) private var postsInBox
  
  var body: some View {
      if postsInBox.count > 0 {
        Section("Posts Box") {
          ScrollView(.horizontal) {
            HStack(spacing: 12) {
              ForEach(postsInBox, id: \.self.id) { post in
                PostInBoxLink(selectedSub: $selectedSub, postInBox: post, post: Post(id: post.id, api: RedditAPI.shared), sub: Subreddit(id: post.subredditName, api: RedditAPI.shared))
                  .animation(spring, value: postsInBox)
              }
            }
          }
          .id("quickPosts")
          .onAppear { Task(priority: .background) { await updatePostsInBox(RedditAPI.shared) } }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
      }
  }
}
