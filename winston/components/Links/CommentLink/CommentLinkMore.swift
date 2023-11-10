//
//  CommentLinkMore.swift
//  winston
//
//  Created by Igor Marcossi on 17/07/23.
//

import SwiftUI
import Defaults

struct CommentLinkMore: View {
  var arrowKinds: [ArrowKind]
  var comment: Comment
  var post: Post?
  var postFullname: String?
  var parentElement: CommentParentElement?
  var indentLines: Int?
  @State var loadMoreLoading = false
  
  @Environment(\.useTheme) private var selectedTheme
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    let curveColor = selectedTheme.comments.theme.indentColor.cs(cs).color()
    let cardedCommentsInnerHPadding = selectedTheme.comments.theme.innerPadding.horizontal
    let horPad = cardedCommentsInnerHPadding
    if let data = comment.data, let count = data.count, let parentElement = parentElement, count > 0 {
      HStack(spacing: 0) {
        if data.depth != 0 && indentLines != 0 {
          HStack(alignment:. bottom, spacing: 6) {
            let shapes = Array(1...Int(indentLines ?? data.depth ?? 1))
            ForEach(shapes, id: \.self) { i in
              if arrowKinds.indices.contains(i - 1) {
                let actualArrowKind = arrowKinds[i - 1]
                Arrows(kind: actualArrowKind, offset: selectedTheme.comments.theme.loadMoreOuterTopPadding)

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
        .padding(.vertical, selectedTheme.comments.theme.loadMoreInnerPadding.vertical)
        .padding(.horizontal, selectedTheme.comments.theme.loadMoreInnerPadding.horizontal)
        .opacity(loadMoreLoading ? 0.5 : 1)
        .background(Capsule(style: .continuous).fill(selectedTheme.comments.theme.loadMoreBackground.cs(cs).color()))
        .compositingGroup()
        .fontSize(selectedTheme.comments.theme.loadMoreText.size, selectedTheme.comments.theme.loadMoreText.weight.t)
        .foregroundColor(selectedTheme.comments.theme.loadMoreText.color.cs(cs).color())
        .padding(.top, selectedTheme.comments.theme.loadMoreOuterTopPadding)
        .padding(.bottom, 2)
      }
      .padding(.horizontal, horPad)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(selectedTheme.comments.theme.bg.cs(cs).color())
      .contentShape(Rectangle())
      .onTapGesture {
        if let postFullname = postFullname {
          withAnimation(spring) {
            loadMoreLoading = true
          }
          Task(priority: .background) {
            await comment.loadChildren(parent: parentElement, postFullname: postFullname, avatarSize: selectedTheme.comments.theme.badge.avatar.size, post: post)
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
