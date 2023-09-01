//
//  SingleDoubleTapGestureRecognizer.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import Foundation
import UIKit

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
  var maximumTapLength: Double = 0.35
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    delay(delay: maximumTapLength) {
      // Enough time has passed and the gesture was not recognized -> It has failed.
      if self.state != .ended {
        self.state = .failed
      }
    }
  }
  
  func delay(delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
  }
}
