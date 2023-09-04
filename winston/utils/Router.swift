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
}

class RouterProxy: ObservableObject {
  var router: Router
  init(_ router: Router) { self.router = router }
}
