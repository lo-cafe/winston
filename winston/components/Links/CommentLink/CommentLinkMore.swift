//
//  CommentLinkMore.swift
//  winston
//
//  Created by Igor Marcossi on 17/07/23.
//

import SwiftUI
import Defaults

struct CommentLinkMore: View {
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  var arrowKinds: [ArrowKind]
  var comment: Comment
  var postFullname: String?
  var parentElement: CommentParentElement?
  var indentLines: Int?
  @State var loadMoreLoading = false
  
  @Default(.cardedCommentsInnerHPadding) var cardedCommentsInnerHPadding

  var body: some View {
    let horPad = preferenceShowCommentsCards ? cardedCommentsInnerHPadding : 0
    if let data = comment.data, let count = data.count, let parentElement = parentElement, count > 0 {
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
        HStack {
          Image(systemName: "plus.message.fill")
          Text(loadMoreLoading ? "Just a sec..." : "Load \(count == 0 ? "some" : String(count)) more")
        }
        .padding(.vertical, 12)
        .compositingGroup()
        .opacity(loadMoreLoading ? 0.5 : 1)
      }
      .padding(.horizontal, cardedCommentsInnerHPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(preferenceShowCommentsCards ? Color.listBG : .clear)
      .contentShape(Rectangle())
      .onTapGesture { Task {
        if let postFullname = postFullname {
          await MainActor.run {
            withAnimation(spring) {
              loadMoreLoading = true
            }
          }
          await comment.loadChildren(parent: parentElement, postFullname: postFullname)
          await MainActor.run {
            doThisAfter(0.5) {
              withAnimation(spring) {
                loadMoreLoading = false
              }
            }
          }
        }
      } }
      .allowsHitTesting(!loadMoreLoading)
      .id("\(comment.id)-more")
    } else {
      Text("Depressive load more :(")
    }
  }
}
