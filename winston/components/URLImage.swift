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
    return lhs.url == rhs.url
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
          if let image = state.image {
            image.resizable()
          } else if state.error != nil {
            Color.red.opacity(0.1)
              .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
          } else {
            Image(.loader)
              .resizable()
              .scaledToFill()
              .mask(Circle())
              .frame(maxWidth: 50, maxHeight: 50)
          }
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
            Image(.loader)
              .resizable()
              .scaledToFill()
              .mask(Circle())
              .frame(maxWidth: 50, maxHeight: 50)
          }
        }
        .onDisappear(.cancel)
        .processors(processors)
      }
      
    }
  }
}


//extension ImageRequest: Equatable {
//  public static func == (lhs: Nuke.ImageRequest, rhs: Nuke.ImageRequest) -> Bool {
//    lhs.url == rhs.url
//  }
//}
