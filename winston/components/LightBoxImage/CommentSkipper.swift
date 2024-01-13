//
//  CommentSkipper.swift
//  OpenArtemis
//
//  Created by daniel on 12/8/23.
//

import SwiftUI

struct CommentSkipper: ViewModifier {
  @Environment(\.useTheme) private var selectedTheme
  @Binding var showJumpToNextCommentButton: Bool
  @Binding var topVisibleCommentId: String?
  @Binding var previousScrollTarget: String?
  var comments: ObservableArray<Comment>
  var reader: ScrollViewProxy
  
  func body(content: Content) -> some View {
    content.overlay {
      if showJumpToNextCommentButton {
        HStack {
        
          if selectedTheme.posts.inlineFloatingPill {
            Spacer()
          }
          
          VStack {
            Spacer()
            Button {
              Hap.shared.play(intensity: 0.75, sharpness: 0.9)
              withAnimation {
                jumpToNextComment()
              }
            } label: {
              Label("Jump to Next Comment", systemImage: "chevron.down")
                .labelStyle(.iconOnly)
                .padding()
                .background(
                  Circle()
                    .foregroundStyle(.thinMaterial)
                )
            }
          }
          .padding()
          
          if !selectedTheme.posts.inlineFloatingPill {
            Spacer()
          }
        }
      }
    }
  }
  
  private func jumpToNextComment() {
    if topVisibleCommentId == nil, let id = comments.data.first?.id {
      reader.scrollTo(id, anchor: .top)
      topVisibleCommentId = id
      return
    }
    
    if let topVisibleCommentId = topVisibleCommentId {
      let topVisibleCommentIndex = comments.data.map { $0.id }.firstIndex(of: topVisibleCommentId) ?? 0
      if topVisibleCommentId == previousScrollTarget {
        let nextIndex = min(topVisibleCommentIndex + 1, comments.data.count - 1)
        reader.scrollTo(comments.data[nextIndex].id, anchor: .top)
        previousScrollTarget = nextIndex < comments.data.count - 1 ? comments.data[nextIndex + 1].id : nil
      } else {
        let nextIndex = min(topVisibleCommentIndex + 1, comments.data.count - 1)
        reader.scrollTo(comments.data[nextIndex].id, anchor: .top)
        previousScrollTarget = topVisibleCommentId
      }
    }
  }
}

extension View {
  func commentSkipper(
    showJumpToNextCommentButton: Binding<Bool>,
    topVisibleCommentId: Binding<String?>,
    previousScrollTarget: Binding<String?>,
    comments: ObservableArray<Comment>,

    reader: ScrollViewProxy
  ) -> some View {
    modifier(
      CommentSkipper(
        showJumpToNextCommentButton: showJumpToNextCommentButton,
        topVisibleCommentId: topVisibleCommentId,
        previousScrollTarget: previousScrollTarget,
        comments: comments,
        reader: reader
      )
    )
  }
}
