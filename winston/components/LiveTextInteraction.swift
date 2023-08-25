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
    imageView.image = image.asUIImage() //we need to convert the Image into an UIImage
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
      catch {
        // Handle error…
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

//found on https://stackoverflow.com/a/64005395
extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
 // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
