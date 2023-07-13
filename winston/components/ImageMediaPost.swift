//
//  ImageMediaPost.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI
import Kingfisher
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
  @State var isPresenting = false
  @Namespace var presentationNamespace
  //  @EnvironmentObject var lightBoxType: ContentLightBox
//  @EnvironmentObject var namespaceWrapper: TabberNamespaceWrapper
  
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
    if let data = post.data {
      ZStack {
        if !isPresenting {
          KFImage(URL(string: data.url)!)
            .resizable()
            .fade(duration: 0.5)
            .backgroundDecode()
            .matchedGeometryEffect(id: "\(data.url)-img", in: presentationNamespace)
            .scaledToFill()
            .zIndex(1)
            .frame(width: contentWidth, height: height)
            .allowsHitTesting(false)
        }
      }
      .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
      //      .mask(RR(12, .black).matchedGeometryEffect(id: "\(data.url)-\(prefix)mask", in: namespaceWrapper.namespace))
      .mask(RR(12, .black))
      .contentShape(Rectangle())
      .swipyActions(
        disableSwipe: parentOffsetX == nil,
        disableFunctions: true,
        pressing: $pressing,
        parentDragging: parentDragging,
        parentOffsetX: parentOffsetX,
        onTap: {
          withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
            isPresenting.toggle()
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
      .fullscreenPresent(show: $isPresenting) {
        LightBoxImage(imgURL: URL(string: data.url)!, post: post, namespace: presentationNamespace)
      }
    } else {
      Color.clear
        .frame(width: contentWidth, height: height)
        .zIndex(1)
    }
  }
}
