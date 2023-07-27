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
  @State var isPresenting = false
  @Namespace var presentationNamespace
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  
  var contentWidth: CGFloat { UIScreen.screenWidth - (POSTLINK_OUTER_H_PAD * 2) - (preferenceShowPostsCards ? POSTLINK_INNER_H_PAD * 2 : 0) }
    
  var body: some View {
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    if let data = post.data, let preview = data.preview, preview.images?.count ?? 0 > 0, let source = preview.images?[0].source, let _ = source.url, let sourceHeight = source.height, let sourceWidth = source.width {
      let propHeight = (Int(contentWidth) * sourceHeight) / sourceWidth
      let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(Int(maxHeight), propHeight)) : Double(propHeight)
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
        .frame(width: contentWidth, height: finalHeight)
      }
      .frame(maxWidth: .infinity)
      //      .mask(RR(12, .black).matchedGeometryEffect(id: "\(data.url)-\(prefix)mask", in: namespaceWrapper.namespace))
      .mask(RR(12, .black))
      .contentShape(Rectangle())
      .transition(.offset(x: 0, y: 1))
      .onTapGesture {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 25)) {
          isPresenting.toggle()
        }
      }
      .fullscreenPresent(show: $isPresenting) {
        LightBoxImage(size: CGSize(width: sourceWidth, height: sourceHeight), imgURL: URL(string: data.url)!, post: post, namespace: presentationNamespace)
      }
    } else {
      Text("Error loding image")
        .frame(width: contentWidth, height: 500)
        .zIndex(1)
    }
  }
}
