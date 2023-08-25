//
//  LiveTextInteraction.swift
//  winston
//
//  Created by Daniel Inama on 25/08/23.
//

import UIKit
import SwiftUI
import VisionKit

@MainActor
struct LiveTextInteraction: UIViewRepresentable {
  var image: Image
  let imageView = LiveTextImageView()
  let analyzer = ImageAnalyzer()
  let interaction = ImageAnalysisInteraction()
  
  
  func makeUIView(context: Context) -> some UIView {
    imageView.image = ImageRenderer(content: image).uiImage //we need to convert the Image into an UIImage
    imageView.addInteraction(interaction)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    Task {
      let configuration = ImageAnalyzer.Configuration([.text])
      do {
        if let image = imageView.image {
          let analysis = try? await analyzer.analyze(image, configuration: configuration)
          if let analysis = analysis {
            interaction.preferredInteractionTypes = .textSelection
            interaction.analysis = analysis;
          }
        }
      }
      
    }
  }
}


class LiveTextImageView: UIImageView {
  // Use intrinsicContentSize to change the default image size
  // so that we can change the size in our SwiftUI View
  override var intrinsicContentSize: CGSize {
    .zero
  }
  
}

