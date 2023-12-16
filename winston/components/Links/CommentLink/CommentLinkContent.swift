//
//  CommentLinkContent.swift
//  winston
//
//  Created by Igor Marcossi on 08/07/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect

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
    if let data = comment.data, let winstonData = comment.winstonData {
      VStack(alignment: .leading, spacing: 0) {
        CommentLinkContent(forcedBodySize: sizer.size, showReplies: showReplies, arrowKinds: arrowKinds, indentLines: indentLines, lineLimit: lineLimit, post: post, comment: comment, winstonData: winstonData, avatarsURL: avatarsURL)
      }
      .frame(width: .screenW, height: sizer.size.height + CGFloat((data.depth != 0 ? 42 : 30) + 16))
    }
  }
}

struct CommentLinkContent: View {
  static let indentLineContentSpacing: Double = 4
  static let indentLinesSpacing: Double = 6
  
  var disableBG = false
  var highlightID: String?
  var seenComments: String?
  var forcedBodySize: CGSize?
  var showReplies = true
  var arrowKinds: [ArrowKind]
  var indentLines: Int? = nil
  var lineLimit: Int?
  var post: Post?
  @ObservedObject var comment: Comment
  @ObservedObject var winstonData: CommentWinstonData
  var avatarsURL: [String:String]?

  @State private var sizer = Sizer()
  @State private var showReplyModal = false
  @State private var pressing = false
  @State private var dragging = false
  @State private var offsetX: CGFloat = 0
  @State private var bodySize: CGSize = .zero
  @State private var highlight = false
  @State private var commentSwipeActions: SwipeActionsSet = Defaults[.CommentLinkDefSettings].swipeActions
  
  @Default(.CommentLinkDefSettings) private var defSettings
  @Default(.CommentsSectionDefSettings) private var sectionDefSettings
  
  @Environment(\.useTheme) private var selectedTheme
  
  @State var commentViewLoaded = false
  
  nonisolated func haptic() {
    Task(priority: .background) {
      let medium = await UIImpactFeedbackGenerator(style: .medium)
      await medium.prepare()
      await medium.impactOccurred()
    }
  }
  
  var body: some View {    
    let theme = selectedTheme.comments
    let selectable = (comment.data?.winstonSelecting ?? false)
    let horPad = theme.theme.innerPadding.horizontal
    
    
    if let data = comment.data {
      let collapsed = data.collapsed ?? false
      Group {
        
        HStack(spacing: CommentLinkContent.indentLineContentSpacing) {
          if data.depth != 0 && indentLines != 0 {
            HStack(alignment:. bottom, spacing: CommentLinkContent.indentLinesSpacing) {
              let shapes = Array(1...Int(indentLines ?? data.depth ?? 1))
              ForEach(shapes, id: \.self) { i in
                if arrowKinds.indices.contains(i - 1) {
                  let actualArrowKind = arrowKinds[i - 1]
                  Arrows(kind: actualArrowKind, offset: theme.theme.innerPadding.vertical + theme.theme.repliesSpacing)
                }
              }
            }
          }
          HStack(spacing: 8) {
            if let author = data.author {
              BadgeView(avatarRequest: winstonData.avatarImageRequest, saved: data.badgeKit.saved, unseen: seenComments == nil ? false : !seenComments!.contains(data.id), usernameColor: (post?.data?.author ?? "") == author ? Color.green : nil, author: data.badgeKit.author,fullname: data.badgeKit.authorFullname, userFlair: data.badgeKit.userFlair, created: data.badgeKit.created, theme: theme.theme.badge, commentTheme: theme.theme)
            }
            
            Spacer()
            
            if (data.saved ?? false) {
              Image(systemName: "bookmark.fill")
                .fontSize(14)
                .foregroundColor(.green)
                .transition(.scale.combined(with: .opacity))
            }
            
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
              .onTapGesture { withAnimation { comment.data?.winstonSelecting = false } }
            }
            
            if let ups = data.ups {
              HStack(alignment: .center, spacing: 4) {
                Image(systemName: "arrow.up")
                  .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)
                  .contentShape(Rectangle())
                  .onTapGesture {
                    
                    Task {
                      haptic()
                      _ = await comment.vote(action: .up)
                    }
                  }
                
                let downup = Int(ups)
                Text(formatBigNumber(downup))
                  .foregroundColor(data.likes != nil ? (data.likes! ? .orange : .blue) : .gray)
                  .contentTransition(.numericText())
                
                //                  .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                  .fontSize(14, .semibold)
                
                Image(systemName: "arrow.down")
                  .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
                  .contentShape(Rectangle())
                  .onTapGesture {
                    
                    Task {
                      haptic()
                      _ = await comment.vote(action: .down)
                    }
                  }
              }
              .fontSize(14, .medium)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Capsule(style: .continuous).fill(.secondary.opacity(0.1)))
              //              .viewVotes(ups, downs)
              .allowsHitTesting(!collapsed)
              .scaleEffect(1)
              
              if collapsed {
                Image(systemName: "eye.slash.fill")
                  .fontSize(14, .medium)
                  .opacity(0.5)
                  .allowsHitTesting(false)
              }
              
            }
          }
          .padding(.top, data.depth != 0 ? theme.theme.innerPadding.vertical + theme.theme.repliesSpacing : 0)
          .compositingGroup()
          .opacity(collapsed ? 0.5 : 1)
          .offset(x: offsetX)
          .animation(draggingAnimation, value: offsetX)
          .padding(.top, data.depth != 0 ? 6 : 0)
          .contentShape(Rectangle())
          .swipyUI(
            controlledDragAmount: $offsetX,
            controlledIsSource: false,
            onTap: { withAnimation(spring) { comment.toggleCollapsed(optimistic: true) } },
            actionsSet: commentSwipeActions,
            entity: comment
          )
        }
        .introspect(.listCell, on: .iOS(.v16, .v17)) { cell in
          cell.layer.masksToBounds = false
        }
        .padding(.horizontal, horPad)
        .frame(height: max(((theme.theme.badge.authorText.size * 1.2) + (theme.theme.badge.statsText.size * 1.2) + 2), theme.theme.badge.avatar.size) + (data.depth != 0 ? theme.theme.innerPadding.vertical + theme.theme.repliesSpacing : 0) + (data.depth != 0 ? 6 : 0), alignment: .leading)
        .mask(Color.black)
        .background(Color.accentColor.opacity(highlight ? 0.2 : 0))
        .background(!disableBG && showReplies ? theme.theme.bg() : .clear)
        .onAppear {
          let newCommentSwipeActions = Defaults[.CommentLinkDefSettings].swipeActions
          if commentSwipeActions != newCommentSwipeActions {
            commentSwipeActions = newCommentSwipeActions
          }
          if var specificID = highlightID {
            specificID = specificID.hasPrefix("t1_") ? String(specificID.dropFirst(3)) : specificID
            if specificID == data.id { withAnimation { highlight = true } }
            doThisAfter(0.1) {
              withAnimation(.easeOut(duration: 4)) { highlight = false }
            }
          }
        }
        .onAppear() {
          if !commentViewLoaded && sectionDefSettings.collapseAutoModerator {
            if data.depth == 0 && data.author == "AutoModerator" && !(data.collapsed ?? false) {
              comment.toggleCollapsed(optimistic: true)
            }
          } else {
            commentViewLoaded = true
          }
        }
        .id("\(data.id)-header\(forcedBodySize == nil ? "" : "-preview")")
        
        if !collapsed {
          HStack(spacing: CommentLinkContent.indentLineContentSpacing) {
            if data.depth != 0 && indentLines != 0 {
              HStack(alignment:. bottom, spacing: CommentLinkContent.indentLinesSpacing) {
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
                      .lineLimit(lineLimit)
                  } else {
                    MD2(winstonData.bodyAttr == nil ? .str(body) : .nsAttr(winstonData.bodyAttr!), fontSize: theme.theme.bodyText.size, onTap: { if !selectable { withAnimation(spring) { comment.toggleCollapsed(optimistic: true) } } })
                      .frame(width: winstonData.commentBodySize.width, height: winstonData.commentBodySize.height, alignment: .topLeading)
                      .fixedSize()
                      .overlay(
                        !selectable
                        ? nil
                        : TextViewWrapper(attributedText: NSAttributedString(body.md()), maxLayoutWidth: sizer.size.width)
                          .frame(width: sizer.size.width, height: sizer.size.height, alignment: .topLeading)
                          .background(Rectangle().fill(theme.theme.bg()))
                      )
                  }
                }
                .fontSize(theme.theme.bodyText.size, theme.theme.bodyText.weight.t)
                .foregroundColor(theme.theme.bodyText.color())
              }
              .onChange(of: theme) { newTheme in
                let encoder = JSONEncoder()
                if let jsonData = try? encoder.encode(stringToAttr(body, fontSize: newTheme.theme.bodyText.size)) {
                  let json = String(decoding: jsonData, as: UTF8.self)
                  comment.data?.winstonBodyAttrEncoded = json
                }
              }
              //              .padding(.leading, 6)
              .frame(maxWidth: .infinity, alignment: .topLeading)
              .offset(x: offsetX)
              .animation(draggingAnimation, value: offsetX)
              .padding(.top, theme.theme.bodyAuthorSpacing)
              .padding(.bottom, data.depth == 0 && comment.childrenWinston.data.count == 0 ? 0 : theme.theme.innerPadding.vertical)
              .scaleEffect(1)
              .contentShape(Rectangle())
              .swipyUI(
                offsetYAction: -15,
                controlledDragAmount: $offsetX,
                //                onTap: { if !selectable { withAnimation(spring) { comment.toggleCollapsed(optimistic: true) } } },
                actionsSet: commentSwipeActions,
                entity: comment
              )
              .background(forcedBodySize != nil ? nil : GeometryReader { geo in Color.clear.onAppear { sizer.size = geo.size } } )
            } else {
              Spacer()
            }
          }
          .introspect(.listCell, on: .iOS(.v16, .v17)) { cell in
            cell.layer.masksToBounds = false
          }
          .padding(.horizontal, horPad)
          .mask(Color.black.padding(.top, -(data.depth != 0 ? 42 : 30)).padding(.bottom, -8))
          .background(Color.accentColor.opacity(highlight ? 0.2 : 0))
          .background(showReplies ? theme.theme.bg() : .clear)
          .id("\(data.id)-body\(forcedBodySize == nil ? "" : "-preview")")
        }
      }
      .contextMenu {
        if !selectable && forcedBodySize == nil {
          ForEach(allCommentSwipeActions) { action in
            let active = action.active(comment)
            if action.enabled(comment) {
              Button {
                Task(priority: .background) {
                  await action.action(comment)
                }
              } label: {
                Label(active ? "Undo \(action.label.lowercased())" : action.label, systemImage: active ? action.icon.active : action.icon.normal)
                  .foregroundColor(action.bgColor.normal == "353439" ? action.color.normal == "FFFFFF" ? Color.blue : Color.hex(action.color.normal) : Color.hex(action.bgColor.normal))
              }
            }
          }
          
          if let permalink = data.permalink, let permaURL = URL(string: "https://reddit.com\(permalink.escape.urlEncoded)") {
            ShareLink(item: permaURL) { Label("Share", systemImage: "square.and.arrow.up") }
          }
          
        }
      } preview: {
        CommentLinkContentPreview(sizer: sizer, forcedBodySize: sizer.size, showReplies: showReplies, arrowKinds: arrowKinds, indentLines: indentLines, lineLimit: lineLimit, post: post, comment: comment, avatarsURL: avatarsURL)
          .id("\(data.id)-preview")
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
    content.frame(height: disable ? nil : height, alignment: .topLeading)
  }
}
