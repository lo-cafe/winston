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
import SwiftyUI

struct URLImage: View, Equatable {
  static func == (lhs: URLImage, rhs: URLImage) -> Bool {
    lhs.url == rhs.url && lhs.imgRequest?.url == rhs.imgRequest?.url
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
          GIFImage(data: imageData, size: size)
            .scaledToFit()
            
            .frame(width: size?.width, height: size?.height)
        } else if state.error != nil {
          Color.red.opacity(0.1)
            .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
        } else {
            URLImageLoader(size: 50).equatable().scaledToFit()
        }
      }
      .onDisappear(.cancel)
      .processors(processors)
    } else {
      if let imgRequest = imgRequest {
        LazyImage(request: imgRequest, transaction: .init(animation: .default)) { state in
//          if case .success(let response) = state.result {
//            AltImage(image: response.image, size: size)
////            Image(uiImage: response.image).resizable()
//          }
          if let image = state.image {
            if doLiveText && ImageAnalyzer.isSupported {
              LiveTextInteraction(image: image)
                .scaledToFit()
                
                .frame(width: size?.width, height: size?.height)
            } else {
              image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size?.width, height: size?.height)
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
                
                    .frame(width: size?.width, height: size?.height)
                .scaledToFit()
            } else {
              image
                .resizable()
                .frame(width: size?.width, height: size?.height)
                .scaledToFit()
            }
          } else if state.error != nil {
            Color.red.opacity(0.1)
              .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
          } else {
              URLImageLoader(size: 50).equatable().scaledToFit()
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
  var size: CGSize
  
  var body: some View {
    LazyImage(request: imgRequest, transaction: .init(animation: .default)) { state in
//                if case .success(let response) = state.result {
////                  Image(uiImage: response.image).resizable()
//                  AltImage(image: response.image, size: size)
//                }
//      if let image = state.imageContainer?.image {
      if let image = state.image {
        image
      } else {
        Color.acceptablePrimary.opacity(0.3)
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
      .scaledToFit()
      .mask(Circle())
      .opacity(0.5)
      .frame(maxWidth: size, maxHeight: size)
  }
}

//struct BetterImageView: UIViewRepresentable {
//  var uiImage: UIImage
//  var size: CGSize
//  
//  func makeUIView(context: Context) -> UIView {
//    let view = SwiftyImageView(uiImage)
//    view.frame.size = size
//    return view
//  }
//  
//  func updateUIView(_ uiView: UIView, context: Context) { }
//}
