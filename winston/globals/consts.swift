//
//  consts.swift
//  winston
//
//  Created by Igor Marcossi on 20/07/23.
//

import Foundation
import UIKit
import SwiftUI
import HighlightedTextEditor

let IPAD = UIDevice.current.userInterfaceIdiom == .pad
let spring = Animation.interpolatingSpring(stiffness: 300, damping: 30, initialVelocity: 0)
let draggingAnimation = Animation.interpolatingSpring(stiffness: 1000, damping: 75, initialVelocity: 0)
let collapsedPresentation = PresentationDetent.height(75)
let compactModeThumbSize: CGFloat = 75
let screenScale = UIScreen.main.scale
let feedsAndSuch = ["home", "saved", "all", "popular"]
let IMAGES_FORMATS = [".png", ".jpg", ".jpeg", ".webp", ".bmp", ".tiff", ".svg", ".ico", ".heic", ".heif"]
let VIDEOS_FORMATS = [".gif", ".mov", ".mp4", ".avi", ".mkv", ".flv", ".wmv", ".mpg", ".mpeg", ".webm"]

func getSafeArea()->UIEdgeInsets{
  let keyWindow = UIApplication
    .shared
    .connectedScenes
    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
    .first
  return (keyWindow?.safeAreaInsets)!
}

extension String {
    var urlEncoded: String {
      return self.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
//        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "~-_."))
//        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}
