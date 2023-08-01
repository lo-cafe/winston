//
//  dismissKeyboard.swift
//  winston
//
//  Created by Igor Marcossi on 01/08/23.
//

import Foundation
import UIKit

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
