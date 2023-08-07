//
//  KeyWindow.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import UIKit

extension UIApplication {
  var currentKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .map { $0 as? UIWindowScene }
      .compactMap { $0 }
      .first?.windows
      .filter { $0.isKeyWindow }
      .first
  }

  var rootViewController: UIViewController? {
    currentKeyWindow?.rootViewController
  }

//  var visibleViewController: UIViewController? {
//    currentKeyWindow?.visibleViewController
//  }
}
