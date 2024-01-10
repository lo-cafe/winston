//
//  ScaleFixer.swift
//  winston
//
//  Created by Igor Marcossi on 10/01/24.
//

import Foundation
import Nuke
import UIKit

extension ImageProcessors {
    public struct ScaleFixer: ImageProcessing, Hashable, CustomStringConvertible {
        public func process(_ image: PlatformImage) -> PlatformImage? {
          let scale = CGFloat.screenScale
          return UIGraphicsImageRenderer(size: CGSize(width: image.size.width/scale, height: image.size.height/scale)).image { _ in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: image.size.width/scale, height: image.size.height/scale)))
          }
        }

        public var identifier: String {
            return "com.github.kean/nuke/scale-fixer"
        }

        public var description: String {
            "ScaleFixer()"
        }
    }
}
