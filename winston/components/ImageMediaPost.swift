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

struct GalleryThumb: View {
  var width: CGFloat
  var height: CGFloat
  var url: URL
  var body: some View {
    KFImage(url)
      .downsampling(size: CGSize(width: width * screenScale, height: height * screenScale))
      .scaleFactor(screenScale)
      .resizable()
      .fade(duration: 0.5)
      .backgroundDecode()
      .scaledToFill()
      .zIndex(1)
      .frame(width: width, height: height)
      .mask(RR(12, .black))
  }
}

struct ImageMediaPost: View {
  var prefix: String = ""
  var post: Post
  var altContentWidth: CGFloat?
  @State var pressing = false
  @State var fullscreen = false
  @State var fullscreenIndex = 0
  @Namespace var presentationNamespace
  @Default(.preferenceShowPostsCards) var preferenceShowPostsCards
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  
  var safe: Double { getSafeArea().top + getSafeArea().bottom }
  
  var rawContentWidth: CGFloat { UIScreen.screenWidth - (POSTLINK_OUTER_H_PAD * 2) - (preferenceShowPostsCards ? POSTLINK_INNER_H_PAD * 2 : 0) }
  
  var body: some View {
    let contentWidth = altContentWidth ?? rawContentWidth
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    if let data = post.data {
      ZStack {
        if let preview = data.preview, preview.images?.count ?? 0 > 0, let source = preview.images?[0].source, let _ = source.url, let sourceHeight = source.height, let sourceWidth = source.width {
          let propHeight = (Int(contentWidth) * sourceHeight) / sourceWidth
          let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(Int(maxHeight), propHeight)) : Double(propHeight)
          GalleryThumb(width: contentWidth, height: finalHeight, url: URL(string: data.url)!)
            .onTapGesture { withAnimation(spring) { fullscreen.toggle() } }
//            .frame(width: contentWidth, height: finalHeight)
        } else if data.is_gallery == true, let metadatas = data.media_metadata?.values, metadatas.count > 1 {
          let urls: [String] = metadatas.compactMap { x in
            if let extArr = x.m?.split(separator: "/") {
              let ext = extArr[extArr.count - 1]
              return "https://i.redd.it/\(x.id).\(ext)"
            }
            return nil
          }
          let width = (contentWidth - 8) / 2
          let height = width
          
          VStack(spacing: 8) {
            HStack(spacing: 8) {
              GalleryThumb(width: width, height: height, url: URL(string: urls[0])!)
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 0
                  doThisAfter(0) { fullscreen.toggle() }
                } }
              GalleryThumb(width: width, height: height, url: URL(string: urls[1])!)
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 1
                  doThisAfter(0) { fullscreen.toggle() }
                } }
            }
            
            
            if urls.count > 2 {
              HStack(spacing: 8) {
                GalleryThumb(width: urls.count == 3 ? contentWidth: width, height: height, url: URL(string: urls[2])!)
                  .onTapGesture { withAnimation(spring) {
                    fullscreenIndex = 2
                    doThisAfter(0) { fullscreen.toggle() }
                  } }
                if urls.count == 4 {
                  GalleryThumb(width: width, height: height, url: URL(string: urls[3])!)
                    .onTapGesture { withAnimation(spring) {
                      fullscreenIndex = 3
                      doThisAfter(0) { fullscreen.toggle() }
                    } }
                } else {
                  Text("\(urls.count - 3)+")
                    .fontSize(24, .medium)
                    .frame(width: width - 24, height: height - 24)
                    .frame(width: width, height: height)
                    .background(Circle().fill(.primary.opacity(0.075)))
                    .onTapGesture { withAnimation(spring) {
                      fullscreenIndex = 0
                      doThisAfter(0) { fullscreen.toggle() }
                    } }
                }
              }
//              .frame(width: contentWidth, height: height)
            }
            
          }
        }
      }
      .frame(maxWidth: .infinity)
      .fullscreenPresent(show: $fullscreen) {
        LightBoxImage(post: post, i: fullscreenIndex, namespace: presentationNamespace)
      }
    } else {
      Text("Error loding image")
        .frame(width: contentWidth, height: 500)
        .zIndex(1)
    }
  }
}
