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

struct GalleryThumb: View {
  var ns: Namespace.ID
  var width: CGFloat
  var height: CGFloat
  var url: URL
  var body: some View {
    LazyImage(url: url) { state in
      if let image = state.image {
        image.resizable().scaledToFill()
      } else if state.error != nil {
        Color.red // Indicates an error
      } else {
        Color.blue // Acts as a placeholder
      }
    }
    .processors([.resize(width: width)])
    .zIndex(1)
    .allowsHitTesting(false)
    .frame(width: width, height: height)
    .clipped()
    .mask(RR(12, .black))
    .contentShape(Rectangle())
  }
}

let IMAGES_FORMATS = [".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"]

struct ImageMediaPost: View {
  var compact = false
  var prefix: String = ""
  var post: Post
  var contentWidth: CGFloat
  @State var pressing = false
  @State var fullscreen = false
  @State var fullscreenIndex = 0
  @Namespace var presentationNamespace
  @Default(.maxPostLinkImageHeightPercentage) var maxPostLinkImageHeightPercentage
  
  var body: some View {
    EmptyView()
    let maxHeight: CGFloat = (maxPostLinkImageHeightPercentage / 100) * (UIScreen.screenHeight - safe)
    if let data = post.data {
      VStack {
        if let preview = data.preview, preview.images?.count ?? 0 > 0, let source = preview.images?[0].source, let srcURL = source.url, let sourceHeight = source.height, let sourceWidth = source.width, let imgURL = URL(string: (data.url.contains("imgur.com") && !IMAGES_FORMATS.contains(String(data.url.suffix(4)))) ? srcURL : data.url) {

          let propHeight = (Int(contentWidth) * sourceHeight) / sourceWidth
          let finalHeight = maxPostLinkImageHeightPercentage != 110 ? Double(min(Int(maxHeight), propHeight)) : Double(propHeight)

          GalleryThumb(ns: presentationNamespace, width: compact ? compactModeThumbSize : contentWidth, height: compact ? compactModeThumbSize : finalHeight, url: imgURL)
            .onTapGesture { withAnimation(spring) { fullscreen.toggle() } }

        } else if data.is_gallery == true, let metadatas = data.media_metadata?.values, metadatas.count > 1 {
          let urls: [String] = metadatas.compactMap { x in
            if let x = x, !x.id.isNil, let id = x.id, !id.isEmpty, let extArr = x.m?.split(separator: "/") {
              let ext = extArr[extArr.count - 1]
              return "https://i.redd.it/\(id).\(ext)"
            }
            return nil
          }
          let width = (contentWidth - 8) / 2
          let height = width

          VStack(spacing: 8) {
            HStack(spacing: 8) {
              GalleryThumb(ns: presentationNamespace, width: compact ? compactModeThumbSize : width, height: compact ? compactModeThumbSize : height, url: URL(string: urls[0])!)
                .onTapGesture { withAnimation(spring) {
                  fullscreenIndex = 0
                  doThisAfter(0) { fullscreen.toggle() }
                } }
                .overlay(
                  !compact
                  ? nil
                  : Text("\(urls.count - 1)+")
                    .fontSize(24, .semibold)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RR(12, .black.opacity(0.2)))
                    .allowsHitTesting(false)
                )
              if !compact {
                GalleryThumb(ns: presentationNamespace, width: width, height: height, url: URL(string: urls[1])!)
                  .onTapGesture { withAnimation(spring) {
                    fullscreenIndex = 1
                    doThisAfter(0) { fullscreen.toggle() }
                  } }
              }
            }


            if urls.count > 2 && !compact {
              HStack(spacing: 8) {
                GalleryThumb(ns: presentationNamespace, width: urls.count == 3 ? contentWidth : width, height: height, url: URL(string: urls[2])!)
                  .onTapGesture { withAnimation(spring) {
                    fullscreenIndex = 2
                    doThisAfter(0) { fullscreen.toggle() }
                  } }
                if urls.count == 4 {
                  GalleryThumb(ns: presentationNamespace, width: width, height: height, url: URL(string: urls[3])!)
                    .onTapGesture { withAnimation(spring) {
                      fullscreenIndex = 3
                      doThisAfter(0) { fullscreen.toggle() }
                    } }
                } else if urls.count > 4 {
                  Text("\(urls.count - 3)+")
                    .fontSize(24, .medium)
                    .frame(width: width - 24, height: height - 24)
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
        LightBoxImage(post: post, i: fullscreenIndex, namespace: presentationNamespace)
      })
//      .fullscreenPresent(show: $fullscreen) {
//      }
    } else {
      Text("Error loding image")
        .frame(width: contentWidth, height: 500)
        .zIndex(1)
    }
  }
}
