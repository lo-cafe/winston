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
let draggingAnimation = Animation.interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 0)
let collapsedPresentation = PresentationDetent.height(75)
let screenScale = UIScreen.main.scale

func getSafeArea()->UIEdgeInsets{
  let keyWindow = UIApplication
    .shared
    .connectedScenes
    .compactMap { ($0 as? UIWindowScene)?.keyWindow }
    .first
  return (keyWindow?.safeAreaInsets)!
}
