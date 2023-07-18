//
//  CommentLinkFull.swift
//  winston
//
//  Created by Igor Marcossi on 17/07/23.
//

import SwiftUI

struct CommentLinkFull: View {
  var post: Post
  var subreddit: Subreddit
  var arrowKinds: [ArrowKind]
  var comment: Comment
  var indentLines: Int?
  @State var loadMoreLoading = false
  @State var opened = false
  @State var id = UUID().uuidString
  var body: some View {
    if let data = comment.data {
      HStack {
        if data.depth != 0 && indentLines != 0 {
          HStack(alignment:. bottom, spacing: 6) {
            let shapes = Array(1...Int(indentLines ?? data.depth ?? 1))
            ForEach(shapes, id: \.self) { i in
              if arrowKinds.indices.contains(i - 1) {
                let actualArrowKind = arrowKinds[i - 1]
                Arrows(kind: actualArrowKind)
              }
            }
          }
        }
        VStack {
          HStack {
            Image(systemName: "plus.message.fill")
            Text(loadMoreLoading ? "Just a sec..." : "View full conversation")
          }
          .background(
            NavigationLink(destination: PostView(post: post, subreddit: subreddit), isActive: $opened, label: { EmptyView().opacity(0).allowsHitTesting(false).disabled(true) }).buttonStyle(PlainButtonStyle()).opacity(0).frame(width: 0, height: 0).allowsHitTesting(false).disabled(true)
          )
          .allowsHitTesting(false)
          .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          opened = true
        }
        
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .allowsHitTesting(!loadMoreLoading)
      .opacity(loadMoreLoading ? 0.5 : 1)
      .id("\(comment.id)-\(id)")
    } else {
      Text("Depressive load more :(")
    }
  }
}
