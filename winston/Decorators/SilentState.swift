//
//  SilentState.swift
//  winston
//
//  Created by Igor Marcossi on 22/01/24.
//

import SwiftUI

@propertyWrapper
class SilentState<Value> {
    var wrappedValue: Value {
        didSet {}
    }
    
    var projectedValue: Binding<Value> {
        Binding<Value>(
            get: { self.wrappedValue },
            set: { newValue in self.wrappedValue = newValue }
        )
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
