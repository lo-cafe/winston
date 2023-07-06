//
//  ImageMediaPost.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI
import SDWebImageSwiftUI
import Defaults
import VideoPlayer
import CoreMedia
import ASCollectionView

struct ImageMediaPost: View {
  var parentDragging: Binding<Bool>?
  var parentOffsetX: Binding<CGFloat>?
  var prefix: String = ""
  var post: Post
  var leftAction: (()->())?
  var rightAction: (()->())?
  @State var pressing = false
  @State var contentWidth: CGFloat = .zero
  @EnvironmentObject var lightBoxType: ContentLightBox
  @EnvironmentObject var namespaceWrapper: NamespaceWrapper
  
  init(parentDragging: Binding<Bool>? = nil, parentOffsetX: Binding<CGFloat>? = nil, prefix: String = "", post: Post, leftAction: (()->())? = nil, rightAction: (()->())? = nil) {
    if let parentOffsetX = parentOffsetX {
      self.parentOffsetX = parentOffsetX
    }
    if let parentDragging = parentDragging {
      self.parentDragging = parentDragging
    }
    self.post = post
    self.prefix = prefix
    self.leftAction = leftAction
    self.rightAction = rightAction
  }
  
  var body: some View {
    let height: CGFloat = 150
    if lightBoxType.post != post, let data = post.data {
      ZStack {
        WebImage(url: URL(string: data.url))
          .resizable()
          .placeholder {
            RR(12, .gray.opacity(0.5))
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
//        Image("cat")
//          .matchedGeometryEffect(id: "\(data.url)-\(prefix)img", in: namespaceWrapper.namespace)
          .transition(.fade(duration: 0.5))
          .scaledToFill()
          .zIndex(1)
          .frame(width: contentWidth, height: height)
          .allowsHitTesting(false)
      }
      .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
//      .mask(RR(12, .black).matchedGeometryEffect(id: "\(data.url)-\(prefix)mask", in: namespaceWrapper.namespace))
      .mask(RR(12, .black))
      .contentShape(Rectangle())
      .swipyActions(disableSwipe: parentOffsetX == nil, disableFunctions: true, pressing: $pressing, parentDragging: parentDragging, parentOffsetX: parentOffsetX, onTap: {
        if lightBoxType.post == nil {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
              lightBoxType.post = post
          }
        }
      }, leftActionHandler: {
        leftAction?()
      }, rightActionHandler: {
        rightAction?()
      })


      .transition(.offset(x: 0, y: 1))
      .background(
        GeometryReader { geo in
          Color.clear
            .onAppear {
              contentWidth = geo.size.width
            }
            .onChange(of: geo.size.width) { val in
              contentWidth = val
            }
        }
      )
    } else {
      Color.clear
        .frame(width: contentWidth, height: height)
        .zIndex(1)
    }
  }
}
