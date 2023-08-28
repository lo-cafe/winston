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

struct URLImage: View {
  let url: URL
  var processors: [ImageProcessing]? = nil
  var doLiveText: Bool = false
  var body: some View {
    LazyImage(url: url, transaction: Transaction(animation: .default)) { state in
      if let image = state.image {
        if doLiveText && ImageAnalyzer.isSupported {
          LiveTextInteraction(image: image)
        } else {
          image
            .resizable()
            .scaledToFit()
        }
      } else if state.error != nil {
        Color.red.opacity(0.1)
          .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
      } else {
        Color.gray.opacity(0.1).transition(.opacity)
      }
    }
    .processors(processors)
    
  }
}
