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
      self.cancellables.append($0.objectWillChange.sink(receiveValue: { _ in
        self.objectWillChange.send()
      }))
      if let comment = $0 as? GenericRedditEntity<CommentData, CommentWinstonData>, let wd = comment.winstonData {
        self.cancellables.append(wd.objectWillChange.sink(receiveValue: { _ in self.objectWillChange.send() }))
      }
    })
  }
}

class NonObservableArray<T: ObservableObject>: ObservableObject {
  @Published var data:[T] = []
}
