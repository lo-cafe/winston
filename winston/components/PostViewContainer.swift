//
//  PostViewContainer.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import SwiftUI

struct PostViewContainer: View {
  @StateObject var post: Post
  @StateObject var sub: Subreddit
  var fromMessage: MessageData?
    var body: some View {
      PostView(post: post, subreddit: sub, fromMessage: fromMessage)
    }
}

//struct PostViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        PostViewContainer()
//    }
//}
