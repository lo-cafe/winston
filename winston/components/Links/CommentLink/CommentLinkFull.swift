//
//  CommentLinkFull.swift
//  winston
//
//  Created by Igor Marcossi on 17/07/23.
//

import SwiftUI
import Defaults

struct CommentLinkFull: View {
  var post: Post
  var arrowKinds: [ArrowKind]
  var comment: Comment
  var indentLines: Int?
  @State private var loadMoreLoading = false
  @State private var id = UUID().uuidString
  @Environment(\.useTheme) private var selectedTheme
  
  var body: some View {
    let curveColor = selectedTheme.comments.theme.indentColor()
    let horPad = selectedTheme.comments.theme.innerPadding.horizontal
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
          .allowsHitTesting(false)
          .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
        
      }
      .padding(.horizontal, horPad)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(curveColor)
      .contentShape(Rectangle())
      .onTapGesture {
        Nav.to(.reddit(.post(post)))
      }
      .allowsHitTesting(!loadMoreLoading)
      .opacity(loadMoreLoading ? 0.5 : 1)
      .id("\(comment.id)-\(id)")
    } else {
      Text("Depressive load full :(")
    }
  }
}
