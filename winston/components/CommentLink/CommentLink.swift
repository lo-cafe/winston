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


class SubCommentsReferencesContainer: ObservableObject {
  @Published var data: [Comment] = []
}

struct CommentLink: View {
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  var post: Post?
  var subreddit: Subreddit?
  var arrowKinds: [ArrowKind] = []
  var indentLines: Int? = nil
  var lineLimit: Int?
  var lastOne = true
  @Binding var disableScroll: Bool
  var avatarsURL: [String:String]? = nil
  var disableShapeShift = true
  var postFullname: String?
  var showReplies = true
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  
  var parentElement: CommentParentElement? = nil
  @ObservedObject var comment: Comment
  @State var loadMoreLoading = false
  @State var collapsed = false
  @State var wholeThingHeight: CGFloat?
  
  @State var isRoot = false
  @State var hasChild = false
  @State var actualLastOne = false
  @State var initiated = false
  
  //  var getBGPos: CommentBGSide {
  //    if !showReplies { return .single }
  //    if let data = comment.data {
  //      let isRoot = data.depth == 0
  //      let hasChild = comment.childrenWinston.data.count != 0
  //      let actualLastOne = (lastOne && !hasChild && !isRoot)
  //
  //      if isRoot && (!hasChild || collapsed) {
  //        return .single
  //      } else if isRoot && hasChild {
  //        return .top
  //      } else if (actualLastOne || (lastOne && collapsed)) && !isRoot {
  //        return .bottom
  //      } else {
  //        return .middle
  //      }
  //    } else {
  //      return .single
  //    }
  //  }
  
  var body: some View {
    if let data = comment.data {
      Group {
        
        Group {
          if let kind = comment.kind, kind == "more" {
            if comment.id == "_" {
              if let post = post, let subreddit = subreddit {
                CommentLinkFull(post: post, subreddit: subreddit, arrowKinds: arrowKinds, comment: comment, indentLines: indentLines)
              }
            } else {
              CommentLinkMore(arrowKinds: arrowKinds, comment: comment, postFullname: postFullname, parentElement: parentElement, indentLines: indentLines)
            }
          } else {
            CommentLinkContent(arrowKinds: arrowKinds, indentLines: indentLines, lineLimit: lineLimit, comment: comment, avatarsURL: avatarsURL, showReplies: showReplies, collapsed: $collapsed)
          }
        }
//        .frame(width: UIScreen.screenWidth - 16)
//        .fixedSize(horizontal: true, vertical: false)
//        .introspect(.listCell, on: .iOS(.v16, .v17)) { cell in
//          cell.frame.size.width = UIScreen.screenWidth - 16
//        }
//        .fixedSize(horizontal: true, vertical: false)
        
        if let _ = data.replies, !collapsed && showReplies {
          ForEach(Array(comment.childrenWinston.data.enumerated()), id: \.element.id) { index, commentChild in
            let childrenCount = comment.childrenWinston.data.count
            if let _ = commentChild.data {
              CommentLink(arrowKinds: arrowKinds.map { $0.child } + [(childrenCount - 1 == index ? ArrowKind.curve : ArrowKind.straightCurve)], disableScroll: $disableScroll, disableShapeShift: index == 0, postFullname: postFullname, parentElement: .comment(comment), comment: commentChild)
            }
          }
        }
        
      }
      
    } else {
      Text("Oops")
    }
  }
}
