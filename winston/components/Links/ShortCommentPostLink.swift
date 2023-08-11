//
//  ShortCommentPostLink.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI
import Defaults
struct ShortCommentPostLink: View {
  @EnvironmentObject private var router: Router
  var comment: Comment
  @State var openedPost = false
  @State var openedSub = false
  @Default(.coloredCommentNames) var coloredCommentNames
  var body: some View {
    if let data = comment.data, let _ = data.link_id, let _ = data.subreddit {
      //      Button {
      
      //      } label: {
      VStack(alignment: .leading, spacing: 6) {
        Text(data.link_title ?? "Error")
          .fontSize(15, .medium)
          .allowsHitTesting(false)
          .opacity(0.75)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .allowsHitTesting(false)
          .fixedSize(horizontal: false, vertical: true)
        
        VStack(alignment: .leading, spacing: 2) {
          if let author = data.author {
            (Text("by ").font(.system(size: 13, weight: .medium)).foregroundColor(.primary.opacity(0.5)) + Text(author).font(.system(size: 13, weight: .semibold)).foregroundColor(coloredCommentNames ? .blue : .primary))
              .onTapGesture { router.path.append(User(id: data.author!, api: comment.redditAPI)) }
          }
          
          if let subreddit = data.subreddit {
            (Text("on ").font(.system(size: 13, weight: .medium)).foregroundColor(.primary.opacity(0.5)) + Text("r/\(subreddit)").font(.system(size: 14, weight: .semibold)).foregroundColor(.primary.opacity(0.75)))
              .onTapGesture { router.path.append(SubViewType.posts(Subreddit(id: data.subreddit!, api: comment.redditAPI))) }
          }
        }
      }
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RR(14, .secondary.opacity(0.075))
          .onTapGesture {
            openedPost = true
          }
      )
      .onTapGesture {
        router.path.append(PostViewPayload(post: Post(id: data.link_id!, api: comment.redditAPI), sub: Subreddit(id: data.subreddit!, api: comment.redditAPI)))
      }
      .mask(RR(14, .black))
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
    } else {
      Text("Oops")
    }
  }
}
