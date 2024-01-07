//
//  openFromWebListener.swift
//  winston
//
//  Created by Igor Marcossi on 10/12/23.
//

import SwiftUI

extension View {
  func openFromWebListener() -> some View {
    self
      .onOpenURL { url in
        let parsed = parseRedditURL(url.absoluteString)
        withAnimation {
          switch parsed {
          case .post(let postID, let subID):
            Nav.fullTo(.posts, .reddit(.post(Post(id: postID, subID: subID))))
          case .subreddit(let name):
            Nav.fullTo(.posts, .reddit(.subFeed(Subreddit(id: name))))
          case .user(let username):
            Nav.fullTo(.posts, .reddit(.user(User(id: username))))
          default:
            break
          }
        }
      }
  }
}
