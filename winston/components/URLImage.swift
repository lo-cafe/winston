//
//  URLImage.swift
//  winston
//
//  Created by Igor Marcossi on 19/08/23.
//

import SwiftUI
import NukeUI
import Nuke
import NukeExtensions
import VisionKit

struct URLImage: View, Equatable {
  static func == (lhs: URLImage, rhs: URLImage) -> Bool {
    lhs.url == rhs.url
  }
  
  let url: URL
  var doLiveText: Bool = false
  var imgRequest: ImageRequest? = nil
  var pipeline: ImagePipeline? = nil
  var processors: [ImageProcessing]? = nil
  var size: CGSize?
  
  var body: some View {
    if url.absoluteString.hasSuffix(".gif") {
      LazyImage(url: url) { state in
        if let imageData = state.imageContainer?.data {
          GIFImage(data: imageData)
        } else if state.error != nil {
          Color.red.opacity(0.1)
            .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
        } else {
          URLImageLoader(size: 50).equatable()
        }
      }
      .onDisappear(.cancel)
      .processors(processors)
//      GIFImage(url: url)
//        .scaledToFill()
//      AsyncGiffy(url: url) { phase in
//        switch phase {
//        case .loading:
//          ProgressView()
//        case .error:
//          Text("Failed to load GIF")
//        case .success(let giffy):
//          giffy.scaledToFit()
//        }
//      }
    } else {
      if let imgRequest = imgRequest {
        LazyImage(request: imgRequest) { state in
//          if case .success(let response) = state.result {
//            AltImage(image: response.image, size: size)
////            Image(uiImage: response.image).resizable()
//          }
          if let image = state.image {
            if doLiveText && ImageAnalyzer.isSupported {
              LiveTextInteraction(image: image)
                .scaledToFill()
            } else {
              image
                .resizable()
                .scaledToFit()
            }
          // } else if state.error != nil {
          //   Color.red.opacity(0.1)
          //     .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
          // } else {
          //   Image(.loader)
          //     .resizable()
          //     .scaledToFill()
          //     .mask(Circle())
          //     .frame(maxWidth: 50, maxHeight: 50)
          }
        }
        .onDisappear(.cancel)
//        .id("\(imgRequest.url?.absoluteString ?? "")-nuke")
      } else {
        LazyImage(url: url) { state in
          if let image = state.image {
            if doLiveText && ImageAnalyzer.isSupported {
              LiveTextInteraction(image: image)
                .scaledToFill()
            } else {
              image
                .resizable()
                .scaledToFit()
            }
          } else if state.error != nil {
            Color.red.opacity(0.1)
              .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
          } else {
            URLImageLoader(size: 50).equatable()
          }
        }
        .onDisappear(.cancel)
        .processors(processors)
      }
      
    }
  }
}

struct ThumbReqImage: View, Equatable {
  static func == (lhs: ThumbReqImage, rhs: ThumbReqImage) -> Bool {
    lhs.imgRequest.url == rhs.imgRequest.url
  }
  
  var imgRequest: ImageRequest
  var size: CGSize?
  
  var body: some View {
    LazyImage(request: imgRequest) { state in
//                if case .success(let response) = state.result {
////                  Image(uiImage: response.image).resizable()
//                  AltImage(image: response.image, size: size)
//                }
      if let image = state.image {
        image.resizable().aspectRatio(contentMode: .fill)
      }
//      } else if state.error != nil {
//        Color.red.opacity(0.1)
//          .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
//      } else {
//        URLImageLoader(size: 50).equatable()
//      }
    }
    .onDisappear(.cancel)
    //        .id("\(imgRequest.url?.absoluteString ?? "")-nuke")
  }
}


struct URLImageLoader: View, Equatable {
  static func == (lhs: URLImageLoader, rhs: URLImageLoader) -> Bool {
    lhs.size == rhs.size
  }
  
  let size: Double
  
  var body: some View {
    Image(.loader)
      .resizable()
      .scaledToFill()
      .mask(Circle())
      .frame(maxWidth: size, maxHeight: size)
  }
}

//extension ImageRequest: Equatable {
//  public static func == (lhs: Nuke.ImageRequest, rhs: Nuke.ImageRequest) -> Bool {
//    lhs.imageId == rhs.imageId
//  }
//}

//extension FetchImage: Equatable {
//  public static func == (lhs: FetchImage, rhs: FetchImage) -> Bool {
//    lhs.id == rhs.id
//  }
//}
