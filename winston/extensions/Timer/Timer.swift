//
//  Timer.swift
//  winston
//
//  Created by Igor Marcossi on 06/01/24.
//

import SwiftUI

extension Timer {
  convenience init(_ sec: Double, _ cb: @escaping ()->()) {
    self.init(timeInterval: sec, repeats: false) { _ in
      cb()
    }
  }
}
