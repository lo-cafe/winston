//
//  updatePostsInBox.swift
//  winston
//
//  Created by Igor Marcossi on 25/07/23.
//

import Foundation
import Defaults
import SwiftUI

func updatePostsInBox(_ redditAPI: RedditAPI, force: Bool = false) async {
  let postsInBox = Defaults[.postsInBox]
  let postsInBoxNames: [String] = postsInBox.compactMap { post in
    if let lastRefresh = post.lastUpdatedAt, !force, Date().timeIntervalSince1970 - lastRefresh < 120 {
      return nil
    }
    return post.fullname
  }
  if let posts = await RedditAPI.shared.fetchPosts(postFullnames: postsInBoxNames) {
    var postsDict: [String:PostData] = [:]
    posts.forEach { data in
      postsDict[data.name] = data
    }
    let newPostsInBox = postsInBox.map({ post in
      var newPost = post
      if let newData = postsDict[post.fullname] {
        newPost.score = newData.ups
        newPost.commentsCount = newData.num_comments
      }
      return newPost
    })
    await MainActor.run { [newPostsInBox] in
      withAnimation {
        Defaults[.postsInBox] = newPostsInBox
      }
    }
  }
}
