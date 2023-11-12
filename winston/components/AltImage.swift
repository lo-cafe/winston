//
//  AltImage.swift
//  winston
//
//  Created by Igor Marcossi on 27/10/23.
//

import SwiftUI
import UIKit

struct AltImage: UIViewRepresentable, Equatable {
  static func == (lhs: AltImage, rhs: AltImage) -> Bool {
    true
  }
  
  let image: UIImage?
  var size: CGSize?
  
  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView(frame: CGRect(origin: .zero, size: size ?? .zero))
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.clipsToBounds = true
    imageView.layer.shouldRasterize = true
    imageView.layer.rasterizationScale = UIScreen.main.scale
//    imageView.scalesLargeContentImage
    imageView.contentMode = .scaleAspectFill
    
    imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
    imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    imageView.image = image
    
    return imageView
  }
  
  func updateUIView(_ uiView: UIImageView, context: Context) {
//    uiView.frame.size = size ?? .zero
  }
}
