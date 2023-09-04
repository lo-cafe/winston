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
    guard let image = ImageRenderer(content: image).uiImage else {
      imageView.image = UIImage(named: "emptyThumb")
      return imageView
    }
    imageView.image = image
    imageView.addInteraction(interaction)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    Task {
      let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode, .visualLookUp])
      do {
        let analysis = try? await analyzer.analyze(imageView.image!, configuration: configuration)
          if let analysis {
            interaction.preferredInteractionTypes = .automatic
            interaction.isSupplementaryInterfaceHidden = false
            interaction.analysis = analysis;
          }
      }
      
    }
  }
}

@MainActor
struct ZoomableLiveTextInteraction: UIViewRepresentable {
  var image: Image
  let imageView = LiveTextImageView()
  let analyzer = ImageAnalyzer()
  let interaction = ImageAnalysisInteraction()
  
  
  func makeUIView(context: Context) -> some UIView {
    guard let image = ImageRenderer(content: image).uiImage else {
      imageView.image = UIImage(named: "emptyThumb")
      return imageView
    }
    imageView.image = image
    imageView.addInteraction(interaction)
    return imageView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    Task {
      let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode, .visualLookUp])
      do {
        let analysis = try? await analyzer.analyze(imageView.image!, configuration: configuration)
          if let analysis {
            interaction.preferredInteractionTypes = .automatic
            interaction.analysis = analysis;
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
