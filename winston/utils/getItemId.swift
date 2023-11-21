//
//  getFileId.swift
//  winston
//
//  Created by Ethan Bills on 11/16/23.
//

import Foundation

func getItemId(for item: Either<Post, Comment>) -> String {
  // As per API doc: https://www.reddit.com/dev/api/#GET_user_{username}_overview
  switch item {
  case .first(let post):
    return "\(Post.prefix)_\(post.id)"
    
  case .second(let comment):
    return "\(Comment.prefix)_\(comment.id)"
  }
}
