//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI

class Router: ObservableObject {
  @Published var path = NavigationPath()
  @Published var lastPoppedView: PostViewPayload?
}


class RouterProxy: ObservableObject {
  var router: Router
  init(_ router: Router) { self.router = router }
  
  func tryToNavBack(){
    if let lastPoppedView = router.lastPoppedView {
      router.path.append(lastPoppedView)
    } else {
      print("No Last Popped View")
    }
  }
}


extension View {
  @ViewBuilder func capturePoppedView(view: PostViewPayload, in router: Router) -> some View {
    self.onDisappear {
      print("New View Captured")
      router.lastPoppedView = view
    }
  }
}
