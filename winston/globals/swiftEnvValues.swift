//
//  swiftEnvValues.swift
//  winston
//
//  Created by Igor Marcossi on 08/12/23.
//

import Foundation
import SwiftUI
import CoreData

private struct BrighterBGKey: EnvironmentKey {
  static let defaultValue = false
}

private struct PrimaryBGContextKey: EnvironmentKey {
  static let defaultValue: NSManagedObjectContext = PersistenceController.shared.primaryBGContext
}

private struct ChangeAppTabWithPathFuncKey: EnvironmentKey {
  static let defaultValue: (TabIdentifier, NavigationPath) -> () = { _, _ in }
}

private struct ChangeAppTabFuncKey: EnvironmentKey {
  static let defaultValue: (TabIdentifier) -> () = { _ in }
}

private struct CurrentThemeKey: EnvironmentKey {
  static let defaultValue = defaultTheme
}

private struct ContentWidthKey: EnvironmentKey {
  static let defaultValue = UIScreen.screenWidth
}

extension EnvironmentValues {
  var brighterBG: Bool {
    get { self[BrighterBGKey.self] }
    set { self[BrighterBGKey.self] = newValue }
  }
  var primaryBGContext: NSManagedObjectContext {
    get { self[PrimaryBGContextKey.self] }
    set { self[PrimaryBGContextKey.self] = newValue }
  }
  var contentWidth: Double {
    get { self[ContentWidthKey.self] }
    set { self[ContentWidthKey.self] = newValue }
  }
  var useTheme: WinstonTheme {
    get { self[CurrentThemeKey.self] }
    set { self[CurrentThemeKey.self] = newValue }
  }
  var changeAppTabWithPath: (TabIdentifier, NavigationPath) -> () {
    get { self[ChangeAppTabWithPathFuncKey.self] }
    set { self[ChangeAppTabWithPathFuncKey.self] = newValue }
  }
  var changeAppTab: (TabIdentifier) -> () {
    get { self[ChangeAppTabFuncKey.self] }
    set { self[ChangeAppTabFuncKey.self] = newValue }
  }
}

