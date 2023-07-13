//
//  shareMedia.swift
//  winston
//
//  Created by Igor Marcossi on 12/07/23.
//

import Foundation
import UIKit
import SwiftUI

func shareMedia(_ urlString: String, _ mediaType: MediaType) {
    guard let url = URL(string: urlString) else { return }

    var activityItems = [Any]()

    switch mediaType {
    case .image:
        if let imageData = try? Data(contentsOf: url),
           let image = UIImage(data: imageData) {
            activityItems.append(image)
        }
    case .video:
        activityItems.append(url)
    }

    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
       let window = windowSceneDelegate.window,
       let viewController = window?.rootViewController {
        viewController.present(activityController, animated: true)
    }
}
