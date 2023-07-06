//
//  Comment.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import SimpleHaptics
import Defaults

let NEST_LINES_WIDTH: CGFloat = 12

struct CornerShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    //      path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 12))
    //      path.
    path.addArc(center: CGPoint(x: rect.minX + NEST_LINES_WIDTH, y: rect.maxY - NEST_LINES_WIDTH), radius: NEST_LINES_WIDTH, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
    return path
  }
}

class SubCommentsReferencesContainer: ObservableObject {
  @Published var data: [Comment] = []
}

struct CommentLink: View {
  @Default(.preferenceShowCommentsCards) var preferenceShowCommentsCards
  @Default(.preferenceShowCommentsAvatars) var preferenceShowCommentsAvatars
  @Binding var disableScroll: Bool
  var disableShapeShift = true
  var postFullname: String?
  var avatarsURL: [String:String]?
  var lineLimit: Int?
  var showReplies = true
  var refresh: (Bool, Bool) async -> Void
  @EnvironmentObject private var haptics: SimpleHapticGenerator
  
  @ObservedObject var comment: Comment
  //  @StateObject var subCommentsReferencesContainer = SubCommentsReferencesContainer()
  @State var loadMoreLoading = false
  @State var collapsed = false
  @State var prepareCollapsed = false
  @State var enlarging = false
  @State var measure = false
  @State var showReplyModal = false
  @State var needsRefresh = false
  @State var pressing = false
  @State var collapsableHeight: CGFloat = 0
  @State var disableCollapse = true
  //  @State var headerHeight: CGFloat = 0
  @State var collapseTimer: TimerCancellable?
  
  
  var body: some View {
    if let data = comment.data {
      HStack(alignment:. top, spacing: 8) {
        if data.depth != 0 && showReplies {
          VStack(alignment: .leading, spacing: 0) {
            CornerShape()
              .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
              .frame(maxWidth: 12, maxHeight: .infinity)
          }
          //          .background(.red.opacity(0.1))
          .padding(.leading, 1)
          .padding(.bottom, 1)
          .offset(y: disableShapeShift ? 0 : -12)
          .padding(.top, disableShapeShift ? 0 : -12 - 8)
          .padding(.bottom, disableShapeShift ? 12 : 0)
          .frame(maxHeight: collapsed ? 52 : .infinity, alignment: .topLeading)
//          .clipped()
          //          .background(.red)
        }
        VStack(alignment: .leading, spacing: 0) {
          
          VStack (alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
              
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
                    Text("\(downup > 999 ? downup / 1000 : downup)\(downup > 999 ? "K" : "")")
                      .foregroundColor(downup == 0 ? .gray : downup > 0 ? .orange : .blue)
                      .fontSize(14, .semibold)
                    
                    Image(systemName: "arrow.down")
                      .foregroundColor(data.likes != nil && !data.likes! ? .blue : .gray)
                  }
                  .fontSize(14, .medium)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 2)
                  .background(Capsule(style: .continuous).fill(.secondary.opacity(0.1)))
                  .allowsHitTesting(false)
                }
                
                if collapsed {
                  Image(systemName: "eye.slash.fill")
                    .fontSize(14, .medium)
                    .opacity(0.5)
                    .allowsHitTesting(false)
                }
                
              }
              
              if let body = data.body {
                //              GeometryReader { geo in
                Text(body.md())
                  .fontSize(15)
                  .animation(nil, value: collapsed)
                  .clipped()
                  .opacity(collapsed ? 0 : 1)
                  .fixedSize(horizontal: false, vertical: true)
                  .allowsHitTesting(false)
                //                  .frame(maxHeight: collapsed ? 0 : nil, alignment: .topLeading)
              }
            }
            //          .buttonStyle(ShrinkableBtnStyle())
            .contentShape(Rectangle())
            .background(
              RR(20, .secondary.opacity(pressing ? 0.1 : 0))
                .padding(.vertical, -14)
                .padding(.horizontal, -16)
                .allowsHitTesting(false)
            )
            .swipyActions(
              pressing: $pressing,
              onTap: {
                if collapsed {
                  withAnimation(spring) {
                    collapsed = false
                  }
                  collapseTimer = cancelableTimer(0.4, action: {
                    disableCollapse = true
                    collapseTimer = nil
                  })
                } else {
                  if collapseTimer != nil {
                    collapseTimer?.cancel()
                    collapseTimer = nil
                    withAnimation(spring) {
                      collapsed = true
                    }
                  } else {
                    prepareCollapsed = true
                  }
                }
              },
              leftActionHandler: {
                Task {
                  _ = await comment.vote(action: .up)
                }
              }, rightActionHandler: {
                Task {
                  _ = await comment.vote(action: .down)
                }
              }, secondActionHandler: {
                showReplyModal = true
              }, disabled: !showReplies)
            .sheet(isPresented: $showReplyModal) {
              ReplyModal(comment: comment, refresh: refresh)
            }
            
            //            VStack(alignment: .leading) {
            LazyVStack(alignment: .leading, spacing: 0) {
              if showReplies {
                if let replies = data.replies {
                  switch replies {
                  case .first(let data):
                    if data == "lol" {
                      EmptyView()
                    }
                  case .second(let data):
                    if let children = data.data?.children, children.count > 0 {
                      ForEach(Array(comment.childrenWinston.data.enumerated()), id: \.element.id) { index, commentChild in
                        if let childData = commentChild.data {
                          Group {
                            if commentChild.kind == "more" {
                              HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 0) {
                                  CornerShape()
                                    .stroke(Color("divider"), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                    .frame(maxWidth: 12, maxHeight: .infinity)
                                }
                                .padding(.leading, 1)
                                .padding(.bottom, 1)
                                .offset(y: index == 0 ? 0 : -12)
                                .padding(.top, index == 0 ? 0 : -12 - 8)
                                .padding(.bottom, index == 0 ? 12 : 0)
                                
                                MasterButton(icon: "ellipsis.bubble.fill", label: loadMoreLoading ? "Just a sec..." : "Load \(childData.count! == 0 ? "some" : String(childData.count!)) more", mode: .subtle) {
                                  Task {
                                    if let postFullname = postFullname {
                                      withAnimation(spring) {
                                        loadMoreLoading = true
                                      }
                                      
                                      disableScroll = true
                                      measure = true
                                      await commentChild.loadChildren(parent: comment, postFullname: postFullname, preparation: {
                                      }, callback: {
//                                        enlarging = true
//                                        disableScroll = false
                                      })
                                      doThisAfter(0) {
                                        enlarging = true
                                        disableScroll = false
                                        loadMoreLoading = false
                                      }
                                    }
                                  }
                                }
                                .allowsHitTesting(!loadMoreLoading)
                                .opacity(loadMoreLoading ? 0.5 : 1)
                              }
                              .padding(.top, 4)
                            } else if childData.author != nil && childData.author != "" {
                              CommentLink(disableScroll: $disableScroll, disableShapeShift: index == 0, postFullname: postFullname, refresh: refresh, comment: commentChild)
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            .opacity(collapsed ? 0 : 1)
            .allowsHitTesting(!collapsed)
            
          }
          
        }
        .compositingGroup()
        //        .padding(.vertical, (data.depth == 0 || !showReplies) && preferenceShowCommentsCards ? 0 : 6)
        .padding(.top, data.depth != 0 || !showReplies ? 12 : 0)
        .opacity(collapsed ? 0.5 : 1)
        
      }
      .compositingGroup()
      .padding(.bottom, (data.depth == 0 || !showReplies) && preferenceShowCommentsCards ? 14 : 0)
      .padding(.top, (data.depth == 0 || !showReplies) && preferenceShowCommentsCards ? 14 : 8)
      .padding(.horizontal, (data.depth == 0 || !showReplies) && preferenceShowCommentsCards ? 16 : 0)
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .background(
        !prepareCollapsed && !measure && !enlarging
        ? nil
        : GeometryReader { geo in
          Color.clear
            .onAppear {
              if enlarging {
                withAnimation(spring) {
                  collapsableHeight = geo.size.height
                }
                doThisAfter(0.5) {
                  disableCollapse = true
                }
              }
              
              if measure {
                collapsableHeight = geo.size.height
                doThisAfter(0) {
                  disableCollapse = false
                }
              }
                
              if prepareCollapsed {
                collapsableHeight = geo.size.height
                doThisAfter(0) {
                  disableCollapse = false
                  withAnimation(spring) {
                    collapsed = true
                  }
                }
              }
              prepareCollapsed = false
              measure = false
              enlarging = false
            }
        }
      )
      .fixedSize(horizontal: false, vertical: true)
      .modifier(AnimatingCellHeight(height: collapsableHeight == 0 ? 0 : collapsed ? 60 : collapsableHeight + (data.depth == 0 || !showReplies ? 28 : 0), disable: disableCollapse))
      .if((data.depth == 0 || !showReplies) && preferenceShowCommentsCards) { view in
        view
          .background(RR(20, .secondary.opacity(0.15)))
          .mask(RR(20, .black))
      }
      .foregroundColor(.primary)
      .multilineTextAlignment(.leading)
      //      .if(collapsableHeight != 0) { view in
      //      }
    } else {
      Text("Oops")
    }
  }
}

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

//struct Comment_Previews: PreviewProvider {
//    static var previews: some View {
//        Comment()
//    }
//}
