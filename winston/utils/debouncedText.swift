//
//  debouncedText.swift
//  winston
//
//  Created by Igor Marcossi on 27/07/23.
//

import Foundation

class DebouncedText: ObservableObject {
  @Published var text: String = ""
  @Published var debounced: String = ""
  
  init(_ str: String = "", delay: DispatchQueue.SchedulerTimeType.Stride) {
    text = str
    $text.debounce(for: delay, scheduler: DispatchQueue.main).assign(to: &$debounced)
  }
}
