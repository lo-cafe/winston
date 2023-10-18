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
import Giffy

struct URLImage: View, Equatable {
  static func == (lhs: URLImage, rhs: URLImage) -> Bool {
    lhs.url == rhs.url
  }
  
  let url: URL
  var imgRequest: ImageRequest? = nil
  var pipeline: ImagePipeline? = nil
  var processors: [ImageProcessing]? = nil
  
  var body: some View {
    if url.absoluteString.hasSuffix(".gif") {
      AsyncGiffy(url: url) { phase in
        switch phase {
        case .loading:
          ProgressView()
        case .error:
          Text("Failed to load GIF")
        case .success(let giffy):
          giffy.scaledToFit()
        }
      }
    } else {
      if let imgRequest = imgRequest {
        LazyImage(request: imgRequest) { state in
          if case .success(let response) = state.result {
            Image(uiImage: response.image).resizable()
          }
//          if let image = state.image {
//            image
//          } else if state.error != nil {
//            Color.red.opacity(0.1)
//              .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
//          } else {
//            URLImageLoader(size: 50).equatable()
//          }
        }
        .onDisappear(.cancel)
//        .id("\(imgRequest.url?.absoluteString ?? "")-nuke")
      } else {
        LazyImage(url: url) { state in
          if let image = state.image {
            image.resizable()
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
