//
//  ShortCommentPostLink.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI
import Defaults
struct ShortCommentPostLink: View {
  var comment: Comment
  @State var openedPost = false
  @State var openedSub = false
  @Environment(\.useTheme) private var selectedTheme
  var body: some View {
    if let data = comment.data, let _ = data.link_id, let _ = data.subreddit {
      //      Button {
      
      //      } label: {
      VStack(alignment: .leading, spacing: 6) {
        Text(data.link_title ?? "Error")
          .fontSize(15, .medium)
          .opacity(0.75)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
//          .onAppear { attrStrLoader.load(str: data.selftext) }
        
        VStack(alignment: .leading, spacing: 2) {
          if let author = data.author {
            (Text(author).font(.system(size: selectedTheme.postLinks.theme.badge.authorText.size, weight: selectedTheme.postLinks.theme.badge.authorText.weight.t)).foregroundColor(author == "[deleted]" ? .red: selectedTheme.postLinks.theme.badge.authorText.color()))
              .onTapGesture { Nav.to(.reddit(.user(User(id: data.author!)))) }
          }
          
          if let subreddit = data.subreddit {
            (Text("on ").font(.system(size: 13, weight: .medium)).foregroundColor(.primary.opacity(0.5)) + Text("r/\(subreddit)").font(.system(size: 14, weight: .semibold)).foregroundColor(.primary.opacity(0.75)))
              .onTapGesture { Nav.to(.reddit(.subFeed(Subreddit(id: data.subreddit!)))) }
          }
        }
      }
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RR(14, Color.secondary.opacity(0.075))
          .onTapGesture {
            openedPost = true
          }
      )
      .mask(RR(14, Color.black))
      .contentShape(Rectangle())
      .highPriorityGesture (
        TapGesture().onEnded {
          if let link_id = data.link_id, let subID = data.subreddit {
            Nav.to(.reddit(.post(Post(id: link_id, subID: subID))))
          }
        }
      )
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
    } else {
      Text("Oops")
    }
  }
}
