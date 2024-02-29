//
//  takeScreenshot.swift
//  winston
//
//  Created by Igor Marcossi on 27/02/24.
//

import Foundation
import UIKit

func takeScreenshotAndSave() -> UIImage? {
  guard let view = UIApplication.shared.windows.first?.rootViewController?.view else {
    return nil
  }
  let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
  let screenshotImage = renderer.image { context in
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
  }
  return screenshotImage
}
