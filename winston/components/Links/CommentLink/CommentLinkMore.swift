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
    if let data = comment.data, let count = data.count, let parentElement = parentElement, count > 0 {
      HStack(spacing: 0) {
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
          HStack(spacing: 3) {
            HStack(spacing: 0) {
              Text("Load")
              if loadMoreLoading {
                Text("ing")
                  .transition(.scale.combined(with: .opacity))
              }
            }
            Text(count == 0 ? "some" : String(count))
            HStack(spacing: 0) {
              Text("more")
              if loadMoreLoading {
                Text("...")
                  .transition(.scale.combined(with: .opacity))
              }
            }
          }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .opacity(loadMoreLoading ? 0.5 : 1)
        .background(Capsule(style: .continuous).fill(Color("divider")))
        .padding(.vertical, 4)
        .compositingGroup()
        .fontSize(15, .medium)
        .foregroundColor(.blue)
      }
      .padding(.horizontal, cardedCommentsInnerHPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(preferenceShowCommentsCards ? Color.listBG : .clear)
      .contentShape(Rectangle())
      .onTapGesture {
        if let postFullname = postFullname {
          withAnimation(spring) {
            loadMoreLoading = true
          }
          Task(priority: .background) {
            await comment.loadChildren(parent: parentElement, postFullname: postFullname)
            await MainActor.run {
              doThisAfter(0.5) {
                withAnimation(spring) {
                  loadMoreLoading = false
                }
              }
            }
          }
        }
      }
      .allowsHitTesting(!loadMoreLoading)
      .id("\(comment.id)-more")
    } else {
      Text("Depressive load more :(")
    }
  }
}
