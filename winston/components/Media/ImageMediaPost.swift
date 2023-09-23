//
//  ImageMediaPost.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import SwiftUI
import Defaults
import NukeUI
import Nuke

private var safe = getSafeArea().top + getSafeArea().bottom


struct ImageMediaPost: View, Equatable {
  static func == (lhs: ImageMediaPost, rhs: ImageMediaPost) -> Bool {
    lhs.compact == rhs.compact && lhs.contentWidth == rhs.contentWidth && lhs.images == rhs.images
  }
  
  var compact = false
  var post: Post
  var images: [MediaExtracted]
  var contentWidth: CGFloat
  @State var fullscreen = false
  @State var fullscreenIndex = 0
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  
  var body: some View {
    EmptyView()
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    VStack {
      if images.count == 1 {
        let img = images[0]
        let sourceHeight = img.size.height
        let sourceWidth = img.size.width
        
        let propHeight = (contentWidth * sourceHeight) / sourceWidth
        let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
        
        GalleryThumb(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : sourceHeight > 0 ? finalHeight : nil, url: img.url)
          .equatable()
          .onTapGesture { withAnimation(spring) { fullscreen.toggle() } }
          .onAppear {
//            print(post.data?.title)
          }
        
      } else if images.count > 1 {
        
        let width = ((contentWidth - 8) / 2)
        let height = width
        VStack(spacing: 8) {
          HStack(spacing: 8) {
            GalleryThumb(width: compact ? scaledCompactModeThumbSize() : width, height: compact ? scaledCompactModeThumbSize() : height, url: images[0].url)
              .equatable()
              .onTapGesture { withAnimation(spring) {
                fullscreenIndex = 0
                doThisAfter(0) { fullscreen.toggle() }
              } }
              .overlay(
                !compact
                ? nil
                : Text("\(images.count - 1)+")
                  .fontSize(24, .semibold)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .background(RR(12, Color.black.opacity(0.2)))
                  .allowsHitTesting(false)
              )
            if !compact {
              GalleryThumb(width: width, height: height, url: images[1].url)
                .equatable()
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 1
                  doThisAfter(0) { fullscreen.toggle() }
                } }
            }
          }
          
          
          if images.count > 2 && !compact {
            HStack(spacing: 8) {
              GalleryThumb(width: images.count == 3 ? contentWidth : width, height: height, url: images[2].url)
                .equatable()
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 2
                  doThisAfter(0) { fullscreen.toggle() }
                } }
              if images.count == 4 {
                GalleryThumb(width: width, height: height, url: images[3].url)
                  .equatable()
                  .onTapGesture { withAnimation(spring) {
                    fullscreenIndex = 3
                    doThisAfter(0) { fullscreen.toggle() }
                  } }
              } else if images.count > 4 {
                Text("\(images.count - 3)+")
                  .fontSize(24, .medium)
                  .frame(width: width - 32, height: height - 32)
                  .background(Circle().fill(.primary.opacity(0.05)))
                  .frame(width: width, height: height)
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
    .frame(maxWidth: compact ? nil : .infinity)
//    .fullScreenCover(isPresented: $fullscreen, content: {
//      LightBoxImage(post: post, i: fullscreenIndex, imagesArr: images)
//    })
  }
}

/// Either returns the content width or, if compact mode is enabled, the modified content width depending on what setting the user chose
func scaledCompactModeThumbSize() -> CGFloat {
  @Default(.compactMode) var compactMode
  @Default(.compThumbnailSize) var compThumbnailSize
  
  if compactMode {
    return compactModeThumbSize * compThumbnailSize.rawVal
  } else {
    return compactModeThumbSize
  }
}
