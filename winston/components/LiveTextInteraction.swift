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
        if ImageAnalyzer.isSupported {
            imageView.addInteraction(interaction)
        }
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task {
            if ImageAnalyzer.isSupported {
                let configsArray: ImageAnalyzer.AnalysisTypes = [.text, .machineReadableCode] //.visualLookup crashes iOS 16.X devices even if you check for it in an if
                let configuration = ImageAnalyzer.Configuration(configsArray)
                do {
                    if let image = imageView.image{
                        let analysis = try await analyzer.analyze(image, configuration: configuration)
                        interaction.preferredInteractionTypes = .automatic
                        interaction.isSupplementaryInterfaceHidden = false
                        interaction.analysis = analysis;
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}


class LiveTextImageView: UIImageView {
    // Use intrinsicContentSize to change the default image size
    // so that we can change the size in our SwiftUI View
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
}
