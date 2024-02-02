//
//  debouncedText.swift
//  winston
//
//  Created by Igor Marcossi on 27/07/23.
//

import Foundation

@Observable
class Debouncer<V> {
  private var timer = TimerHolder()
  private var delay: Double
  var value: V {
    didSet {
      timer.fireIn(delay) {
        self.debounced = self.value
      }
    }
  }
  private(set) var debounced: V
  
  init(_ val: V, delay: Double = 0.4) {
    value = val
    debounced = val
    self.delay = delay
  }
}
