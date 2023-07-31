//
//  ShortCommentPostLink.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI

struct ShortCommentPostLink: View {
  var comment: Comment
  @State var openedPost = false
  @State var openedAuthor = false
  @State var openedSub = false
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
            (Text("by ").font(.system(size: 13, weight: .medium)).foregroundColor(.primary.opacity(0.5)) + Text(author).font(.system(size: 13, weight: .semibold)).foregroundColor(.blue))
              .onTapGesture {
                openedAuthor = true
              }
              .background(
                NavigationLink(destination: UserView(user: User(id: data.author!, api: comment.redditAPI)), isActive: $openedAuthor, label: { EmptyView().opacity(0).allowsHitTesting(false) }).buttonStyle(EmptyButtonStyle()).opacity(0).frame(width: 0, height: 0).allowsHitTesting(false)
              ) 
          }
          
          if let subreddit = data.subreddit {
            (Text("on ").font(.system(size: 13, weight: .medium)).foregroundColor(.primary.opacity(0.5)) + Text("r/\(subreddit)").font(.system(size: 14, weight: .semibold)).foregroundColor(.primary.opacity(0.75)))
              .onTapGesture {
                openedSub = true
              }
              .background(
                NavigationLink(destination: SubredditPostsContainer(sub: Subreddit(id: data.subreddit!, api: comment.redditAPI)), isActive: $openedSub, label: { EmptyView().opacity(0).allowsHitTesting(false) }).buttonStyle(EmptyButtonStyle()).opacity(0).frame(width: 0, height: 0).allowsHitTesting(false)
              )
          }
        }
      }
      .background(
        NavigationLink(destination: PostView(post: Post(id: data.link_id!, api: comment.redditAPI), subreddit: Subreddit(id: data.subreddit!, api: comment.redditAPI)), isActive: $openedPost, label: { EmptyView().opacity(0).allowsHitTesting(false) }).buttonStyle(EmptyButtonStyle()).opacity(0).frame(width: 0, height: 0).allowsHitTesting(false)
      )
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
      .mask(RR(14, .black))
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
    } else {
      Text("Oops")
    }
  }
}
