//
//  SubredditIcon.swift
//  winston
//
//  Created by Igor Marcossi on 13/07/23.
//

import Foundation
import SwiftUI
import Nuke
import NukeUI

//struct SubredditBaseIcon: View {
//  let name: String
//  let iconURLStr: String?
//  var size: CGFloat = 30
//  let color: String?
//  
////  private static let pipeline = ImagePipeline {
////    $0.dataLoader = DataLoader(configuration: {
////      DataLoader.defaultConfiguration
////    }())
////    
////    $0.imageCache = ImageCache()
////    $0.dataCache = try? DataCache(name: "lo.cafe.winston-cache")
////  }
//  
//  var body: some View {
//  }
//}

struct SubredditIconKit {
  var url: String?
  var initialLetter: String
  var color: String
}

struct SubredditIcon: View {
  var subredditIconKit: SubredditIconKit
  var size: CGFloat = 30
  var body: some View {
    
    if let icon = subredditIconKit.url, !icon.isEmpty, let iconURL = URL(string: icon) {
//      LazyImage(url: iconURL, transaction: Transaction(animation: .default)) { state in
      LazyImage(url: iconURL) { state in
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
      .processors([.resize(width: size)])
//      .pipeline(SubredditBaseIcon.pipeline)
      .scaledToFill()
      .frame(width: size, height: size)
      .mask(Circle())
    } else {
      Text(subredditIconKit.initialLetter)
        .frame(width: size, height: size)
        .background(Color.hex(subredditIconKit.color), in: Circle())
        .mask(Circle())
        .fontSize(CGFloat(Int(size * 0.535)), .semibold)
        .foregroundColor(.primary)
    }
  }
}

func firstNonEmptyString(_ strings: String?...) -> String? {
    for string in strings {
        if let string = string, !string.isEmpty {
            return string
        }
    }
    return nil
}
