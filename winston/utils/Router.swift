//
//  Router.swift
//  winston
//
//  Created by Igor Marcossi on 05/08/23.
//

import Foundation
import SwiftUI

class Router: ObservableObject {
    static var shared = Router()
    @Published var path = NavigationPath()
}
