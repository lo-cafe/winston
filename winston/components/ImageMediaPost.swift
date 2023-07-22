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

struct ImageMediaPost: View {
  var prefix: String = ""
  var post: Post
  @State var pressing = false
  @State var contentWidth: CGFloat = .zero
  @State var isPresenting = false
  @Namespace var presentationNamespace
  
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
      .onTapGesture {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
          isPresenting.toggle()
        }
      }
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
