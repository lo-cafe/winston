//
//  Comment.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import MarkdownUI
import SimpleHaptics

struct CornerShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    //      path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 12))
    //      path.
    path.addArc(center: CGPoint(x: rect.minX + 12, y: rect.maxY - 12), radius: 12, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}


struct CommentLink: View {
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  
  @State var comment: Comment
  @State var collapsed = false
  
  var body: some View {
    if let data = comment.data {
      HStack {
        if data.depth != 0 {
          VStack(alignment: .leading, spacing: 0) {
            CornerShape()
              .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
              .frame(maxWidth: 12, maxHeight: .infinity)
          }
          .padding(.bottom, 12)
          .frame(maxHeight: .infinity, alignment: .leading)
          .opacity(0.1)
        }
        VStack(alignment: .leading) {
          
          VStack(alignment: .leading) {
            
            VStack(alignment: .leading) {
              HStack {
                if let author = data.author {
                  Avatar(userID: author)
                }
                VStack(alignment: .leading) {
                  if let author = data.author {
                    Text(author)
                      .fontSize(15, .semibold)
                    
                    if let created = data.created {
                      let hoursSince = Int((Date().timeIntervalSince1970 - TimeInterval(created)) / 3600)
                      Text("\(hoursSince > 23 ? hoursSince / 24 : hoursSince)\(hoursSince > 23 ? "d" : "h") ago")
                        .fontSize(12)
                        .opacity(0.5)
                    }
                  }
                }
                
                Spacer()
                
                if let ups = data.ups, let downs = data.downs {
                  HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "arrow.up")
                      .foregroundColor(data.likes != nil && data.likes! ? .orange : .gray)
                    
                    let downup = Int(ups - downs)
                    Text("\(downup > 999 ? downup / 1000 : downup)\(downup > 999 ? "K" : "")")
                      .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                      .fontSize(16, .semibold)
                    
                    Image(systemName: "arrow.down")
                      .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
                  }
                  .fontSize(14, .medium)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 2)
                  .background(Capsule(style: .continuous).fill(.secondary.opacity(0.1)))
                }
              }
            }
            
            if let body = data.body {
              Markdown(body)
                .markdownTextStyle {
                  FontSize(15)
                }
            }
          }
          .contentShape(Rectangle())
          .swipyActions(leftActionHandler: {
            Task {
              var newComment = comment
              _ = await newComment.vote(action: .up)
              comment = newComment
            }
          }, rightActionHandler: {
            Task {
              var newComment = comment
               _ = await newComment.vote(action: .down)
              comment = newComment
            }
          }, secondActionHandler: {})
          .simultaneousGesture(
            TapGesture()
              .onEnded {
                withAnimation(spring) {
                  collapsed.toggle()
                }
              }
          )
          
          if let replies = data.replies {
            switch replies {
            case .first(_):
              EmptyView()
            case .second(let data):
              if let children = data.data?.children, children.count > 0 {
                if children[0].kind == "more" {
                  MasterButton(icon: "ellipsis.bubble.fill", label: "Load more") {
                    
                  }
                } else {
                  ForEach(children, id: \.data.id) { commentChild in
                    let comment = Comment(data: commentChild.data, api: comment.redditAPI)
                    CommentLink(comment: comment)
                  }
                }
              }
            }
          }
          
        }
        .padding(.top, data.depth != 0 ? 14 : 0)
      }
      .padding(.vertical, data.depth == 0 ? 14 : 0)
      .padding(.horizontal, data.depth == 0 ? 16 : 0)
      .frame(maxWidth: .infinity, alignment: .leading)
      .if(data.depth == 0) { view in
        view
          .background(RR(20, .secondary.opacity(0.15)))
          .mask(RR(20, .black))
      }
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
    } else {
      Text("Oops")
    }
  }
}

//struct Comment_Previews: PreviewProvider {
//    static var previews: some View {
//        Comment()
//    }
//}
