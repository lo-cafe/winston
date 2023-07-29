//
//  redditURLParser.swift
//  winston
//
//  Created by Igor Marcossi on 29/07/23.
//

import Foundation

enum RedditURLType {
  case post(id: String, subreddit: String)
  case comment(id: String, postID: String, subreddit: String)
  case subreddit(name: String)
  case user(username: String)
  case other
}

func parseRedditURL(_ urlString: String) -> RedditURLType? {
    guard let urlComponents = URLComponents(string: urlString),
          urlComponents.host?.hasSuffix("reddit.com") == true else {
        return nil
    }

    let pathComponents = urlComponents.path.components(separatedBy: "/").filter({ !$0.isEmpty })
    
    if pathComponents.count > 1 {
        switch pathComponents[0] {
        case "r":
            let subredditName = pathComponents[1]
            if pathComponents.count > 2 && pathComponents[2] == "comments" {
                let postId = pathComponents[3]
                if pathComponents.count >= 6 {
                    let commentId = pathComponents[5]
                    return .comment(id: commentId, postID: postId, subreddit: subredditName)
                }
                return .post(id: postId, subreddit: subredditName)
            }
            return .subreddit(name: subredditName)
            
        case "user", "u":
            let username = pathComponents[1]
            return .user(username: username)
            
        default:
            return nil
        }
    }
    
    return nil
}
