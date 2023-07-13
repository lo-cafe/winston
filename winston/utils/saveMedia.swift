//
//  saveMedia.swift
//  winston
//
//  Created by Igor Marcossi on 12/07/23.
//

import Foundation
import Photos
import UIKit

enum MediaType {
    case image
    case video
}

func saveMedia(_ urlString: String, _ mediaType: MediaType, _ completion: ((Bool) -> ())? = nil) {
    guard let url = URL(string: urlString) else { return }

    PHPhotoLibrary.shared().performChanges({
        switch mediaType {
        case .image:
            if let imageData = try? Data(contentsOf: url),
               let image = UIImage(data: imageData) {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        case .video:
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }) { saved, error in
        if saved {
          completion?(true)
            print("\(mediaType) saved successfully")
        } else if let error = error {
          completion?(false)
            print("Error saving \(mediaType): \(error)")
        } else {
          completion?(false)
            print("Unknown error occurred")
        }
    }
}
