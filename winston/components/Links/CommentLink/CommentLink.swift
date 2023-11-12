//
//  Comment.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import Defaults
import SwiftUIIntrospect

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
  
  static func getFromArray(count: Int, i: Int) -> Self {
    if !IPAD { return .middle }
    let finalIndex = count - 1
    if count == 1 { return .single }
    if i == 0 { return .top }
    if i == finalIndex { return .bottom }
    return .middle
  }
}

struct CommentBG: Shape {
  var cornerRadius: CGFloat = 10
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
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    return Path(path.cgPath)
  }
}


class SubCommentsReferencesContainer: ObservableObject {
  @Published var data: [Comment] = []
}

struct CommentLink: View, Equatable {
  static func == (lhs: CommentLink, rhs: CommentLink) -> Bool {
    lhs.post?.data == rhs.post?.data &&
    lhs.subreddit?.data == rhs.subreddit?.data &&
    lhs.indentLines == rhs.indentLines &&
    lhs.highlightID == rhs.highlightID &&
    lhs.comment == rhs.comment
  }
  
  var lineLimit: Int?
  var highlightID: String?
  var post: Post?
  var subreddit: Subreddit?
  var arrowKinds: [ArrowKind] = []
  var indentLines: Int? = nil
  var avatarsURL: [String:String]? = nil
  var postFullname: String?
  var showReplies = true
  
  var parentElement: CommentParentElement? = nil
  @ObservedObject var comment: Comment
  @ObservedObject var commentWinstonData: CommentWinstonData
  @ObservedObject var children: ObservableArray<Comment>
  //  @State var collapsed = false
  
  var body: some View {
    if let data = comment.data {
      let collapsed = data.collapsed ?? false
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
            CommentLinkContent(highlightID: highlightID, showReplies: showReplies, arrowKinds: arrowKinds, indentLines: indentLines, lineLimit: lineLimit, post: post, comment: comment, winstonData: commentWinstonData, avatarsURL: avatarsURL)
          }
        }
        
        if !collapsed && showReplies {
          ForEach(Array(children.data.enumerated()), id: \.element.id) { index, commentChild in
            let childrenCount = children.data.count
            if let _ = commentChild.data, let childCommentWinstonData = commentChild.winstonData {
              CommentLink(post: post, arrowKinds: arrowKinds.map { $0.child } + [(childrenCount - 1 == index ? ArrowKind.curve : ArrowKind.straightCurve)], postFullname: postFullname, parentElement: .comment(comment), comment: commentChild, commentWinstonData: childCommentWinstonData, children: commentChild.childrenWinston)
              //                .equatable()
            }
          }
        }
        
      }
      
    } else {
      Text("Oops")
    }
  }
}

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack {
      configuration.label
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation {
            configuration.isExpanded.toggle()
          }
        }
      if configuration.isExpanded {
        configuration.content
          .disclosureGroupStyle(self)
      }
    }
  }
}
