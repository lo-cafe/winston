//
//  swiftEnvValues.swift
//  winston
//
//  Created by Igor Marcossi on 08/12/23.
//

import Foundation
import SwiftUI
import CoreData

private struct SheetHeightKey: EnvironmentKey {
  static let defaultValue: Double = 0
}

private struct SetTabBarHeightKey: EnvironmentKey {
  static let defaultValue: (Double)->() = { x in }
}

private struct TabBarHeightKey: EnvironmentKey {
  static let defaultValue: Double? = nil
}

private struct BrighterBGKey: EnvironmentKey {
  static let defaultValue = false
}

private struct PrimaryBGContextKey: EnvironmentKey {
  static let defaultValue: NSManagedObjectContext = PersistenceController.shared.primaryBGContext
}

private struct CurrentThemeKey: EnvironmentKey {
  static let defaultValue = defaultTheme
}

private struct ContentWidthKey: EnvironmentKey {
  static let defaultValue: Double = .screenW
}

extension EnvironmentValues {
  var sheetHeight: Double {
    get { self[SheetHeightKey.self] }
    set { self[SheetHeightKey.self] = newValue }
  }
  var setTabBarHeight: (Double)->() {
    get { self[SetTabBarHeightKey.self] }
    set { self[SetTabBarHeightKey.self] = newValue }
  }
  var tabBarHeight: Double? {
    get { self[TabBarHeightKey.self] }
    set { self[TabBarHeightKey.self] = newValue }
  }
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
}

