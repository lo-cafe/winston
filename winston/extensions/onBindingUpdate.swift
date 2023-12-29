//
//  onBindingUpdate.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import Foundation
import SwiftUI

extension Binding {
  func onUpdate(_ closure: @escaping (Value) -> Void) -> Binding<Value> {
    Binding(get: {
      wrappedValue
    }, set: { newValue in
      closure(newValue)
      wrappedValue = newValue
    })
  }
}
