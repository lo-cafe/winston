//
//  CommentLinkContent.swift
//  winston
//
//  Created by Igor Marcossi on 08/07/23.
//

import SwiftUI
import Defaults
import MarkdownUI

class Sizer: ObservableObject {
  @Published var size: CGSize = .zero
}

struct CommentLinkContentPreview: View {
  @ObservedObject var sizer: Sizer
  var forcedBodySize: CGSize?
  var showReplies = true
  var arrowKinds: [ArrowKind]
  var indentLines: Int? = nil
  var lineLimit: Int?
  var post: Post?
  var comment: Comment
  var avatarsURL: [String:String]?
  var body: some View {
    if let data = comment.data {
      VStack(alignment: .leading, spacing: 0) {
        CommentLinkContent(forcedBodySize: sizer.size, showReplies: showReplies, arrowKinds: arrowKinds, indentLines: indentLines, lineLimit: lineLimit, post: post, comment: comment, avatarsURL: avatarsURL)
      }
      .frame(width: UIScreen.screenWidth, height: sizer.size.height + CGFloat((data.depth != 0 ? 42 : 30) + 16))
    }
  }
}

struct CommentLinkContent: View {
  var highlightID: String?
  @Default(.preferenceShowCommentsCards) private var preferenceShowCommentsCards
  @Default(.preferenceShowCommentsAvatars) private var preferenceShowCommentsAvatars
  var forcedBodySize: CGSize?
  var showReplies = true
  var arrowKinds: [ArrowKind]
  var indentLines: Int? = nil
  var lineLimit: Int?
  var post: Post?
  @ObservedObject var comment: Comment
  @State var sizer = Sizer()
  var avatarsURL: [String:String]?
  //  @Binding var collapsed: Bool
  @State var showReplyModal = false
  @State var pressing = false
  @State var dragging = false
  @State var offsetX: CGFloat = 0
  @State var bodySize: CGSize = .zero
  @State var selectable = false
  @State var highlight = false
  
  @Default(.cardedCommentsInnerHPadding) var cardedCommentsInnerHPadding
  @Default(.coloredCommentNames) var coloredCommenNames
  
  @State var viewLoaded = false
  
  var body: some View {
    let horPad = preferenceShowCommentsCards ? cardedCommentsInnerHPadding : 0
    if let data = comment.data {
      let collapsed = data.collapsed ?? false
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
            if let author = data.author, let created = data.created {
              Badge(usernameColor: (post?.data?.author ?? "") == author ? Color.green : (coloredCommenNames ? Color.blue : Color.primary), showAvatar: preferenceShowCommentsAvatars, author: author, fullname: data.author_fullname, created: created, avatarURL: avatarsURL?[data.author_fullname!])
            }
            
            Spacer()
            
            if selectable {
              HStack(spacing: 2) {
                Circle()
                  .fill(.white)
                  .frame(width: 8, height: 8)
                Text("SELECTING")
              }
              .fontSize(13, .medium)
              .foregroundColor(.white)
              .padding(.horizontal, 6)
              .padding(.vertical, 1)
              .background(.orange, in: Capsule(style: .continuous))
              .onTapGesture { withAnimation { selectable = false } }
            }
            
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
            onTap: { withAnimation(spring) { comment.toggleCollapsed(optimistic: true) } },
            leftActionHandler: { Task { _ = await comment.vote(action: .down) } },
            rightActionHandler: { Task { _ = await comment.vote(action: .up) } },
            secondActionHandler: { showReplyModal = true }
          )
        }
        .introspect(.listCell, on: .iOS(.v16, .v17)) { cell in
          cell.layer.masksToBounds = false
        }
        .padding(.horizontal, horPad)
        .padding(.top, data.depth != 0 ? 6 : 0)
        .frame(height: data.depth != 0 ? 42 : 30, alignment: .leading)
        .mask(Color.listBG)
        .background(Color.blue.opacity(highlight ? 0.2 : 0))
        .background(preferenceShowCommentsCards && showReplies ? Color.listBG : .clear)
        .onAppear {
          if var specificID = highlightID {
            specificID = specificID.hasPrefix("t1_") ? String(specificID.dropFirst(3)) : specificID
            if specificID == data.id { withAnimation { highlight = true } }
            doThisAfter(0.1) {
              withAnimation(.easeOut(duration: 4)) { highlight = false }
            }
          }
        }
        .id("\(data.id)-header\(forcedBodySize == nil ? "" : "-preview")")
        
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
              .mask(Rectangle())
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
                      .fixedSize(horizontal: false, vertical: true)
                      .overlay(
                        !selectable
                        ? nil
                        : TextViewWrapper(attributedText: NSAttributedString(body.md()), maxLayoutWidth: sizer.size.width)
                          .frame(width: sizer.size.width, height: sizer.size.height, alignment: .topLeading)
                          .background(Rectangle().fill(Color.listBG))
                      )
                  }
                }
              }
              //              .padding(.leading, 6)
              .frame(maxWidth: .infinity, alignment: .topLeading)
              .offset(x: offsetX)
              .animation(.interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0), value: offsetX)
              .padding(.top, 6)
              .contentShape(Rectangle())
              .swipyUI(
                offsetYAction: -15,
                controlledDragAmount: $offsetX,
                onTap: { if !selectable { withAnimation(spring) { comment.toggleCollapsed(optimistic: true) } } },
                leftActionHandler: { Task { _ = await comment.vote(action: .down) } },
                rightActionHandler: { Task { _ = await comment.vote(action: .up) } },
                secondActionHandler: { showReplyModal = true }
              )
              .background(forcedBodySize != nil ? nil : GeometryReader { geo in Color.clear.onAppear { sizer.size = geo.size } } )
            } else {
              Spacer()
            }
          }
          .introspect(.listCell, on: .iOS(.v16, .v17)) { cell in
            cell.layer.masksToBounds = false
          }
//          .padding(.horizontal, preferenceShowCommentsCards ? 13 : 0)
          .padding(.horizontal, horPad)
          .mask(Color.black.padding(.top, -(data.depth != 0 ? 42 : 30)).padding(.bottom, -8))
          .background(Color.blue.opacity(highlight ? 0.2 : 0))
          .background(preferenceShowCommentsCards && showReplies ? Color.listBG : .clear)
          .contextMenu {
            if !selectable && forcedBodySize == nil {
              Button {
                withAnimation { selectable = true }
              } label: {
                Label("Select text", systemImage: "selection.pin.in.out")
              }
              Button {
                withAnimation { selectable = true }
              } label: {
                Label("Edit", systemImage: "pencil")
              }
              Button(role: .destructive) {
              } label: {
                Label("Delete", systemImage: "trash.fill")
              }
            }
          } preview: {
            CommentLinkContentPreview(sizer: sizer, forcedBodySize: sizer.size, showReplies: showReplies, arrowKinds: arrowKinds, indentLines: indentLines, lineLimit: lineLimit, post: post, comment: comment, avatarsURL: avatarsURL)
              .id("\(data.id)-preview")
          }
          
          .sheet(isPresented: $showReplyModal) {
            ReplyModalComment(comment: comment)
          }
          .id("\(data.id)-body\(forcedBodySize == nil ? "" : "-preview")")
        }
      }
      .onAppear() {
        print("triggered")
        if !viewLoaded {
          if data.author == "AutoModerator" && !(data.collapsed ?? false) {
            comment.toggleCollapsed(optimistic: true)
          }
        } else {
          viewLoaded = true
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
  var disable: Bool = false
  
  var animatableData: CGFloat {
    get { height }
    set { height = newValue }
  }
  
  func body(content: Content) -> some View {
    content.frame(maxHeight: disable ? nil : height, alignment: .topLeading)
  }
}
