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

struct ImageMediaPostCompactMoreImagesOverlay: View, Equatable {
  static func == (lhs: ImageMediaPostCompactMoreImagesOverlay, rhs: ImageMediaPostCompactMoreImagesOverlay) -> Bool {
    return lhs.count == rhs.count
  }
  var count: Int
  var body: some View {
    Text("\(count)+")
      .fontSize(12, .semibold)
      .padding(.all, 6)
      .background(Circle().fill(.bar))
      .padding(.all, 4)
      .allowsHitTesting(false)
  }
}

struct ImageMediaPost: View, Equatable {
  static let gallerySpacing: CGFloat = 8
  static func == (lhs: ImageMediaPost, rhs: ImageMediaPost) -> Bool {
    return lhs.postTitle == rhs.postTitle && lhs.compact == rhs.compact && lhs.contentWidth == rhs.contentWidth && lhs.badgeKit == rhs.badgeKit && lhs.cornerRadius == rhs.cornerRadius
  }
    
  var winstonData: PostWinstonData
  var fullPage = false
  weak var controller: UIViewController?
  let postTitle: String
  let badgeKit: BadgeKit
  let avatarImageRequest: ImageRequest?
  let markAsSeen: (() async -> ())?
  var cornerRadius: Double
  var compact = false
  var images: [ImgExtracted]
  var contentWidth: CGFloat
  var maxMediaHeightScreenPercentage: CGFloat
//  @State var fullscreen = false
  @State var fullscreenIndex: Int?
  
  var body: some View {
//    let maxMediaHeightScreenPercentage = 100.0
    let maxHeight: CGFloat = (maxMediaHeightScreenPercentage / 100) * (.screenH)
    VStack {
      if images.count == 1 || compact && images.count > 0 {
        let img = images[0]
        let sourceHeight = img.size.height
        let sourceWidth = img.size.width
        
        let propHeight = (contentWidth * sourceHeight) / sourceWidth
        let finalHeight = maxMediaHeightScreenPercentage != 110 ? Double(min(maxHeight, propHeight)) : Double(propHeight)
        
        GalleryThumb(cornerRadius: cornerRadius, width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : sourceHeight > 0 ? finalHeight : nil, url: img.url, imgRequest: images.count > 0 ? images[0].request : nil)
              .equatable()
//          .background(sourceHeight > 0 || compact ? nil : GeometryReader { geo in Color.clear.onAppear { winstonData.postDimensions.mediaSize = geo.size }.onChange(of: geo.size) { winstonData.postDimensions.mediaSize = $0 } })
          .onTapGesture { withAnimation(spring) { fullscreenIndex = 0 } }
          .overlay(
            !compact || images.count <= 1
            ? nil
            : ImageMediaPostCompactMoreImagesOverlay(count: images.count - 1).equatable()
            , alignment: .bottomTrailing
          )
        
      } else if images.count > 1 {
        
        let width = ((contentWidth - 8) / 2)
        let height = width
        VStack(spacing: ImageMediaPost.gallerySpacing) {
          HStack(spacing: ImageMediaPost.gallerySpacing) {
            GalleryThumb(cornerRadius: cornerRadius, width: compact ? scaledCompactModeThumbSize() : width, height: compact ? scaledCompactModeThumbSize() : height, url: images[0].url, imgRequest: images.count > 0 ? images[0].request : nil)
              .equatable()
              .onTapGesture { withAnimation(spring) { fullscreenIndex = 0 } }

            GalleryThumb(cornerRadius: cornerRadius, width: width, height: height, url: images[1].url, imgRequest: images.count > 1 ? images[1].request : nil)
              .equatable()
                .onTapGesture { withAnimation(spring) { fullscreenIndex = 1 } }
          }
          
          
          if images.count > 2 {
            HStack(spacing: ImageMediaPost.gallerySpacing) {
              GalleryThumb(cornerRadius: cornerRadius, width: images.count == 3 ? contentWidth : width, height: height, url: images[2].url, imgRequest: images.count > 2 ? images[2].request : nil)
                .equatable()
                .onTapGesture { withAnimation(spring) { fullscreenIndex = 2 } }
              if images.count == 4 {
                GalleryThumb(cornerRadius: cornerRadius, width: width, height: height, url: images[3].url, imgRequest: images.count > 3 ? images[3].request : nil)
                  .equatable()
                  .onTapGesture { withAnimation(spring) { fullscreenIndex = 3 } }
              } else if images.count > 4 {
                Text("\(images.count - 3)+")
                  .fontSize(24, .medium)
                  .frame(width: width - 56, height: height - 56)
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
//    .customPresenter(parentController: controller, isPresented: Binding(get: {
//      fullscreenIndex != nil
//    }, set: { val in
//      if !val { fullscreenIndex = nil }
//    }), content: {
//      LightBoxImage(postTitle: postTitle, badgeKit: badgeKit, markAsSeen: markAsSeen, i: fullscreenIndex ?? 0, imagesArr: images)
//    })
    .fullScreenCover(item: $fullscreenIndex) { i in
      LightBoxImage(postTitle: postTitle, badgeKit: badgeKit, avatarImageRequest: avatarImageRequest, markAsSeen: markAsSeen, i: i, imagesArr: images, doLiveText: Defaults[.BehaviorDefSettings].doLiveText)
    }
  }
}

/// Either returns the content width or, if compact mode is enabled, the modified content width depending on what setting the user chose
func scaledCompactModeThumbSize(compact: Bool = Defaults[.PostLinkDefSettings].compactMode.enabled, thumbnailSize: ThumbnailSizeModifier = Defaults[.PostLinkDefSettings].compactMode.thumbnailSize) -> CGFloat {
  
  if compact {
    return compactModeThumbSize * thumbnailSize.rawVal
  } else {
    return compactModeThumbSize
  }
}

extension Int: Identifiable {
    public var id: Int { self }
}
