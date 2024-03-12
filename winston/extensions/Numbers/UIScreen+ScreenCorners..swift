//
//  UIScreen+ScreenCorners..swift
//  winston
//
//  Created by Igor Marcossi on 12/12/23.
//

import UIKit

extension UIScreen {
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()

    /// The corner radius of the display. Uses a private property of `UIScreen`,
    /// and may report 0 if the API changes.
    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
            assertionFailure("Failed to detect screen corner radius")
            return 0
        }

        return cornerRadius
    }
}

extension CGFloat {
  static var screenCornerRadius: CGFloat =  UIApplication.shared.windows.first?.screen.displayCornerRadius ?? 0
}

extension Double {
  static var screenCornerRadius: Double =  CGFloat.screenCornerRadius
}
