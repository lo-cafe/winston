//
//  CommentLinkContent.swift
//  winston
//
//  Created by Igor Marcossi on 08/07/23.
//

import SwiftUI
import Defaults
import MarkdownUI

struct CommentLinkContent: View {
  @Default(.preferenceShowCommentsAvatars) var preferenceShowCommentsAvatars
  var arrowKinds: [ArrowKind]
  var indentLines: Int? = nil
  var lineLimit: Int?
  @ObservedObject var comment: Comment
  var avatarsURL: [String:String]?
  @Binding var collapsed: Bool
  @State var showReplyModal = false
  @State var pressing = false
  @State var dragging = false
  @State var offsetX: CGFloat = 0
  @State var bodySize: CGSize = .zero
  var body: some View {
    if let data = comment.data {
      Group {
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
            if let author = data.author, let created = data.created  {
              Badge(showAvatar: preferenceShowCommentsAvatars, author: author, fullname: data.author_fullname, created: created, avatarURL: avatarsURL?[data.author_fullname!])
            }

            Spacer()

            if let ups = data.ups, let downs = data.downs {
              HStack(alignment: .center, spacing: 4) {
                Image(systemName: "arrow.up")
                  .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)

                let downup = Int(ups - downs)
                Text(formatBigNumber(downup))
                  .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                  .fontSize(14, .semibold)

                Image(systemName: "arrow.down")
                  .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
              }
              .fontSize(14, .medium)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Capsule(style: .continuous).fill(.secondary.opacity(0.1)))
              .viewVotes(ups, downs)
              .allowsHitTesting(!collapsed)

              if collapsed {
                Image(systemName: "eye.slash.fill")
                  .fontSize(14, .medium)
                  .opacity(0.5)
                  .allowsHitTesting(false)
              }

            }
          }
          .padding(.top, data.depth != 0 ? 6 : 0)
          .compositingGroup()
          .opacity(collapsed ? 0.5 : 1)
          .offset(x: offsetX)
          .animation(draggingAnimation, value: offsetX)
          .contentShape(Rectangle())
          .swipyUI(
            controlledDragAmount: $offsetX,
            controlledIsSource: false,
            onTap: { withAnimation(spring) { collapsed.toggle() } },
            leftActionHandler: { Task { _ = await comment.vote(action: .down) } },
            rightActionHandler: { Task { _ = await comment.vote(action: .up) } },
            secondActionHandler: { showReplyModal = true }
          )
        }
        .padding(.horizontal, 13)
        .padding(.top, data.depth != 0 ? 6 : 0)
        .frame(height: data.depth != 0 ? 42 : 30, alignment: .leading)
        .background(Color.listBG)
        .mask(Color.listBG)
        .id("\(data.id)-header")
        
        if !collapsed {
          HStack {
            if data.depth != 0 && indentLines != 0 {
              HStack(alignment:. bottom, spacing: 6) {
                let shapes = Array(1...Int(indentLines ?? data.depth ?? 1))
                ForEach(shapes, id: \.self) { i in
                  if arrowKinds.indices.contains(i - 1) {
                    let actualArrowKind = arrowKinds[i - 1]
                    Arrows(kind: actualArrowKind.child)
                  }
                }
              }
            }
            if let body = data.body {
              VStack {
                Group {
                  if lineLimit != nil {
                    Text(body.md())
                      .fontSize(15)
                      .lineLimit(lineLimit)
                  } else {
                    MD(str: body)
                  }
                }
//                .animation(nil, value: collapsed)
//                .allowsHitTesting(false)
              }
              .padding(.leading, 6)
              .introspect(.listCell, on: .iOS(.v16, .v17)) { cell in
                cell.layer.masksToBounds = false
              }
              .frame(maxWidth: .infinity, alignment: .topLeading)
              .offset(x: offsetX)
              .animation(.interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0), value: offsetX)
              .padding(.top, 6)
              .contentShape(Rectangle())
              .swipyUI(
                offsetYAction: -15,
                controlledDragAmount: $offsetX,
                onTap: { withAnimation(spring) { collapsed.toggle() } },
                leftActionHandler: { Task { _ = await comment.vote(action: .down) } },
                rightActionHandler: { Task { _ = await comment.vote(action: .up) } },
                secondActionHandler: { showReplyModal = true }
              )
            } else {
              Spacer()
            }
          }
          .padding(.horizontal, 13)
          .background(Color.listBG)
          .mask(Color.listBG)
          .sheet(isPresented: $showReplyModal) {
            ReplyModalComment(comment: comment)
          }
//          .measureOnce($bodySize)
//          .if(bodySize != .zero) { $0.frame(height: bodySize.height) }
          .id("\(data.id)-body")
        }
        
      }
    } else {
      Text("oops")
    }
  }
}

//struct CommentLinkContent_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentLinkContent()
//    }
//}

struct AnimatingCellHeight: AnimatableModifier {
  var height: CGFloat = 0
  var disable: Bool
  
  var animatableData: CGFloat {
    get { height }
    set { height = newValue }
  }
  
  func body(content: Content) -> some View {
    content.frame(maxHeight: disable ? nil : height, alignment: .topLeading)
  }
}
