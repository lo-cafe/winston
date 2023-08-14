//
//  observableArray.swift
//  winston
//
//  Created by Igor Marcossi on 06/07/23.
//

import Foundation
import Combine

class ObservableArray<T: ObservableObject>: ObservableObject {
  @Published var data:[T] = [] {
    didSet { observeChildrenChanges() }
  }
    var cancellables = [AnyCancellable]()

    init(array: [T]? = nil) {
      if let array = array {
        self.data = array
      }
      self.observeChildrenChanges()
    }

    func observeChildrenChanges() {
      cancellables.forEach { cancelable in
        cancelable.cancel()
      }
        data.forEach({
            let c = $0.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() })
            self.cancellables.append(c)
        })
    }
}

class NonObservableArray<T: ObservableObject>: ObservableObject {
  @Published var data:[T] = []
}
