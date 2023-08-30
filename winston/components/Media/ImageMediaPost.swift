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


struct ImageMediaPost: View {
  var compact = false
  var post: Post
  var images: [MediaExtracted]
  var contentWidth: CGFloat
  @State var fullscreen = false
  @State var fullscreenIndex = 0
  @Namespace var presentationNamespace
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
        
        GalleryThumb(ns: presentationNamespace, width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : sourceHeight > 0 ? finalHeight : nil, url: img.url)
          .onTapGesture { withAnimation(spring) { fullscreen.toggle() } }
        
      } else if images.count > 1 {
        
        let width = ((contentWidth - 8) / 2)
        let height = width
        VStack(spacing: 8) {
          HStack(spacing: 8) {
            GalleryThumb(ns: presentationNamespace, width: compact ? scaledCompactModeThumbSize() : width, height: compact ? scaledCompactModeThumbSize() : height, url: images[0].url)
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
                  .background(RR(12, .black.opacity(0.2)))
                  .allowsHitTesting(false)
              )
            if !compact {
              GalleryThumb(ns: presentationNamespace, width: width, height: height, url: images[1].url)
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 1
                  doThisAfter(0) { fullscreen.toggle() }
                } }
            }
          }
          
          
          if images.count > 2 && !compact {
            HStack(spacing: 8) {
              GalleryThumb(ns: presentationNamespace, width: images.count == 3 ? contentWidth : width, height: height, url: images[2].url)
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 2
                  doThisAfter(0) { fullscreen.toggle() }
                } }
              if images.count == 4 {
                GalleryThumb(ns: presentationNamespace, width: width, height: height, url: images[3].url)
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
    .fullScreenCover(isPresented: $fullscreen, content: {
      LightBoxImage(post: post, i: fullscreenIndex, imagesArr: images, namespace: presentationNamespace)
    })
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
