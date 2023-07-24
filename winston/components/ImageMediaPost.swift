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
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  
  var body: some View {
    let height: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    if let data = post.data, let preview = data.preview, preview.images?.count ?? 0 > 0, let source = preview.images?[0].source, let _ = source.url, let sourceHeight = source.height, let sourceWidth = source.width {
      ZStack {
        Group {
          if !isPresenting {
            KFImage(URL(string: data.url)!)
              .resizable()
              .fade(duration: 0.5)
              .backgroundDecode()
//              .matchedGeometryEffect(id: "\(data.url)-img", in: presentationNamespace)
              .scaledToFill()
              .zIndex(1)
            //            .frame(width: contentWidth, height: CGFloat(sourceHeight) > height ? height : CGFloat(sourceHeight))
              .allowsHitTesting(false)
          } else {
            Color.clear
          }
        }
        .frame(width: contentWidth, height: maxPostLinkImageHeightPercentage != 110 ? height : Double(sourceHeight))
      }
      .frame(maxWidth: .infinity)
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
        LightBoxImage(size: CGSize(width: sourceWidth, height: sourceHeight), imgURL: URL(string: data.url)!, post: post, namespace: presentationNamespace)
      }
    } else {
      Color.clear
        .frame(width: contentWidth, height: height)
        .zIndex(1)
    }
  }
}
