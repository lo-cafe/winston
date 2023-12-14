//
//  ConcurrentRunner.swift
//  winston
//
//  Created by Igor Marcossi on 14/12/23.
//

import Foundation
import Dispatch

struct ConcurrentRunner {
  private var tasks: [() -> Void] = []
  
  mutating func add(_ task: @escaping () -> Void) {
    tasks.append(task)
  }
  
  func run(id: String = "") {
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "lo.cafe.winston.concurrentRunner\(id.isEmpty ? "" : ".\(id)")", attributes: .concurrent)
    
    for task in tasks {
      group.enter()
      queue.async {
        task()
        group.leave()
      }
    }
    
    group.wait()
  }
}
