//
//  PostViewContainer.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import SwiftUI

struct PostViewContainerPayload: Hashable {
  let post: Post
  let sub: Subreddit
  var highlightID: String? = nil
}

struct PostViewContainer: View {
  @StateObject var post: Post
  @StateObject var sub: Subreddit
  var highlightID: String?
    var body: some View {
      PostView(post: post, subreddit: sub, highlightID: highlightID).equatable()
    }
  
}

//struct PostViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        PostViewContainer()
//    }
//}
