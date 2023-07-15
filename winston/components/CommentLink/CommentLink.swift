//
//  Comment.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import SimpleHaptics
import Defaults
import SwiftUIIntrospect

let NEST_LINES_WIDTH: CGFloat = 12
let ZINDEX_SLOTS_COMMENT = 100000

struct Top: Shape {
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
    return Path(path.cgPath)
  }
}

enum CommentBGSide {
  case top
  case middle
  case bottom
  case single
}

struct CommentBG: Shape {
  var pos: CommentBGSide
  func path(in rect: CGRect) -> Path {
    var roundingCorners: UIRectCorner = []
    
    switch pos {
    case .top:
      roundingCorners = [.topLeft, .topRight]
    case .middle:
      roundingCorners = []
    case .bottom:
      roundingCorners = [.bottomLeft, .bottomRight]
    case .single:
      roundingCorners = [.bottomLeft, .bottomRight, .topLeft, .topRight]
    }
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: 20, height: 20))
    return Path(path.cgPath)
  }
}

struct LineShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    return path
  }
}
struct CornerShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addArc(center: CGPoint(x: rect.minX + NEST_LINES_WIDTH, y: rect.maxY - NEST_LINES_WIDTH), radius: NEST_LINES_WIDTH, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}

class SubCommentsReferencesContainer: ObservableObject {
  @Published var data: [Comment] = []
}

struct CommentLink: View {
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  var indentLines: Int? = nil
  var lineLimit: Int?
  var lineKinds: [Bool] = []
  var zIndex: Double = 1
  var lastOne = true
  @Binding var disableScroll: Bool
  var avatarsURL: [String:String]? = nil
  var disableShapeShift = true
  var postFullname: String?
  var showReplies = true
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  
  var parentComment: Comment? = nil
  @ObservedObject var comment: Comment
  @State var loadMoreLoading = false
  @State var collapsed = false
  
  @State var isRoot = false
  @State var hasChild = false
  @State var actualLastOne = false
  @State var initiated = false
  
  var getBGPos: CommentBGSide {
    if !showReplies { return .single }
    if let data = comment.data {
      let isRoot = data.depth == 0
      let hasChild = comment.childrenWinston.data.count != 0
      let actualLastOne = (lastOne && !hasChild && !isRoot)
      
      if isRoot && (!hasChild || collapsed) {
        return .single
      } else if isRoot && hasChild {
        return .top
      } else if (actualLastOne || (lastOne && collapsed)) && !isRoot {
        return .bottom
      } else {
        return .middle
      }
    } else {
      return .single
    }
  }
  
  var body: some View {
    if let data = comment.data {
      //      let isRoot = data.depth == 0
      //      let hasChild = comment.childrenWinston.data.count != 0
      //      let actualLastOne = (lastOne && !hasChild && !isRoot)
      Group {
        HStack(alignment:. top, spacing: 8) {
          if data.depth != 0 && indentLines != 0 {
            HStack(alignment:. bottom) {
              let shapes = Array(1...Int(indentLines ?? data.depth ?? 1))
              ForEach(shapes, id: \.self) { i in
                //                let actualDisableShapeShift = i == shapes.count ? true : disableShapeShift
                let actualDisableShapeShift = i == shapes.count && disableShapeShift
                Arrows(disableShapeShift: actualDisableShapeShift)
                //                .frame(maxHeight: collapsed ? 52 : .infinity, alignment: .topLeading)
              }
            }
          }
          if let kind = comment.kind, kind == "more", let count = data.count, let parentComment = parentComment {
            HStack {
              Image(systemName: "plus.message.fill")
              Text(loadMoreLoading ? "Just a sec..." : "Load \(count == 0 ? "some" : String(count)) more")
              //            MasterButton(icon: "ellipsis.bubble.fill", label: loadMoreLoading ? "Just a sec..." : "Load \(count == 0 ? "some" : String(count)) more", mode: .subtle) {
              
            }
            .padding(.vertical, 12)
            .onTapGesture {
              Task {
                if let postFullname = postFullname {
//                  withAnimation(spring) {
//                    loadMoreLoading = true
//                  }
//
//                  disableScroll = true
                  //                  measure = true
                  await comment.loadChildren(parent: parentComment, postFullname: postFullname, preparation: {
                  }, callback: {
                    //                                        enlarging = true
                    //                                        disableScroll = false
                  })
                  doThisAfter(0.7) {
                    //                    enlarging = true
                    disableScroll = false
                    loadMoreLoading = false
                  }
                }
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .allowsHitTesting(!loadMoreLoading)
            .opacity(loadMoreLoading ? 0.5 : 1)
          } else {
            CommentLinkContent(lineLimit: lineLimit, comment: comment, avatarsURL: avatarsURL, showReplies: showReplies, collapsed: $collapsed)
          }
        }
        .compositingGroup()
        //        .padding(.bottom, ((isRoot && !hasChild) || actualLastOne || !showReplies) && preferenceShowCommentsCards ? 6 : 0)
        .padding(.bottom, (isRoot || actualLastOne) && showReplies && preferenceShowCommentsCards ? 14 : 0)
        //        .padding(.top, (isRoot || !showReplies) && preferenceShowCommentsCards ? 6 : 0)
        .padding(.top, (isRoot && showReplies) && preferenceShowCommentsCards ? 14 : 0)
        .padding(.horizontal, preferenceShowCommentsCards && showReplies ? 16 : 0)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        //        .fixedSize(horizontal: false, vertical: true)
        .if(showReplies) { view in
          view.background(CommentBG(pos: getBGPos).fill(Color("commentBG")))
        }
        .padding(.top, parentComment == nil && showReplies ? 12 : 0)
        .foregroundColor(.primary)
        .multilineTextAlignment(.leading)
        .zIndex(zIndex)
        .id(comment.id)
        
        if let replies = data.replies, !collapsed && showReplies {
          //        if comment.childrenWinston.data.count > 0 && showReplies {
          ForEach(Array(comment.childrenWinston.data.enumerated()), id: \.element.id) { index, commentChild in
            let childrenCount = comment.childrenWinston.data.count
            if let dataReply = commentChild.data, let depth = dataReply.depth {
              CommentLink(zIndex: Double(zIndex + (Double(index + 1) / Double(pow(Double(10), Double(max(1, depth)))))), lastOne: lastOne && index == comment.childrenWinston.data.count - 1, disableScroll: $disableScroll, disableShapeShift: index == 0, postFullname: postFullname, parentComment: comment, comment: commentChild)
            }
          }
        }
      }
    } else {
      Text("Oops")
    }
  }
}
