//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI

class RouterIsRoot: ObservableObject {
  @Published var isRoot = true
}

class Router: ObservableObject {
  let id: String
  @Published var path = NavigationPath() {
    willSet {
      objectWillChange.send()
    }
    didSet {
      let isIt = self.path.count == 0
      if self.isRootWrapper.isRoot != isIt { self.isRootWrapper.isRoot = isIt }
    }
  }
  var isRootWrapper = RouterIsRoot()
  
  init(id: String) {
    self.id = id
  }
}

class RouterProxy: ObservableObject {
  var router: Router
  init(_ router: Router) { self.router = router }
}
