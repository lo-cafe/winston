//
//  URLImage.swift
//  winston
//
//  Created by Igor Marcossi on 19/08/23.
//

import SwiftUI
import NukeUI
import Nuke

struct URLImage: View {
  let url: URL
  var processors: [ImageProcessing]? = nil
    var body: some View {
      LazyImage(url: url) { state in
        if let image = state.image {
          image.resizable()
        } else if state.error != nil {
          Color.red.opacity(0.1)
            .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
        } else {
          Color.gray.opacity(0.1) 
        }
      }
      .processors(processors)
    }
}
