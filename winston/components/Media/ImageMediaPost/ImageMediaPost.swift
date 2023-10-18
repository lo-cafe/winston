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

struct ImageMediaPost: View {
  static let gallerySpacing: CGFloat = 8
//  static func == (lhs: ImageMediaPost, rhs: ImageMediaPost) -> Bool {
//    return lhs.images == rhs.images && lhs.compact == rhs.compact && lhs.contentWidth == rhs.contentWidth
//  }
    
  @Binding var postDimensions: PostDimensions
  let postTitle: String
  let badgeKit: BadgeKit
  let markAsSeen: (() async -> ())?
  var cornerRadius: Double
  var compact = false
  let mediaImageRequest: [ImageRequest] = []
  var images: [MediaExtracted]
  var contentWidth: CGFloat
//  @State var fullscreen = false
  @State var fullscreenIndex: Int?
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  
  var body: some View {
//    let maxPostLinkImageHeightPercentage = 100.0
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight)
    VStack {
      if images.count == 1 || compact {
        let img = images[0]
        let sourceHeight = img.size.height
        let sourceWidth = img.size.width
        
        let propHeight = (contentWidth * sourceHeight) / sourceWidth
        let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
        
        GalleryThumb(cornerRadius: cornerRadius, width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : sourceHeight > 0 ? finalHeight : nil, url: img.url, imgRequest: mediaImageRequest.count > 0 ? mediaImageRequest[0] : nil)
          .background(sourceHeight > 0 || compact ? nil : GeometryReader { geo in Color.clear.onAppear { postDimensions.mediaSize = geo.size }.onChange(of: geo.size) { postDimensions.mediaSize = $0 } })
          .onTapGesture { withAnimation(spring) { fullscreenIndex = 0 } }
          .overlay(
            !compact || images.count <= 1
            ? nil
            : Text("\(images.count - 1)+")
              .fontSize(16, .semibold)
              .padding(.all, 8)
              .background(Circle().fill(.bar))
              .padding(.all, 4)
              .allowsHitTesting(false)
            , alignment: .bottomTrailing
          )
        
      } else if images.count > 1 {
        
        let width = ((contentWidth - 8) / 2)
        let height = width
        VStack(spacing: ImageMediaPost.gallerySpacing) {
          HStack(spacing: ImageMediaPost.gallerySpacing) {
            GalleryThumb(cornerRadius: cornerRadius, width: compact ? scaledCompactModeThumbSize() : width, height: compact ? scaledCompactModeThumbSize() : height, url: images[0].url, imgRequest: mediaImageRequest.count > 0 ? mediaImageRequest[0] : nil)
              .onTapGesture { withAnimation(spring) { fullscreenIndex = 0 } }

            GalleryThumb(cornerRadius: cornerRadius, width: width, height: height, url: images[1].url, imgRequest: mediaImageRequest.count > 1 ? mediaImageRequest[1] : nil)
                .onTapGesture { withAnimation(spring) { fullscreenIndex = 1 } }
          }
          
          
          if images.count > 2 {
            HStack(spacing: ImageMediaPost.gallerySpacing) {
              GalleryThumb(cornerRadius: cornerRadius, width: images.count == 3 ? contentWidth : width, height: height, url: images[2].url, imgRequest: mediaImageRequest.count > 2 ? mediaImageRequest[2] : nil)
                .onTapGesture { withAnimation(spring) { fullscreenIndex = 2 } }
              if images.count == 4 {
                GalleryThumb(cornerRadius: cornerRadius, width: width, height: height, url: images[3].url, imgRequest: mediaImageRequest.count > 3 ? mediaImageRequest[3] : nil)
                  .onTapGesture { withAnimation(spring) { fullscreenIndex = 3 } }
              } else if images.count > 4 {
                Text("\(images.count - 3)+")
                  .fontSize(24, .medium)
                  .frame(width: width - 32, height: height - 32)
                  .background(Circle().fill(.primary.opacity(0.05)))
                  .frame(width: width, height: height)
                  .onTapGesture { withAnimation(spring) { fullscreenIndex = 0 } }
              }
            }
            //              .frame(width: contentWidth, height: height)
          }
          
        }
      }
    }
    .frame(maxWidth: compact ? nil : .infinity)
    .fullScreenCover(item: $fullscreenIndex) { i in
      LightBoxImage(postTitle: postTitle, badgeKit: badgeKit, markAsSeen: markAsSeen, i: i, imagesArr: images)
    }
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

extension Int: Identifiable {
    public var id: Int { self }
}
