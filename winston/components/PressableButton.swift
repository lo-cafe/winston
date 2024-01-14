//
//  RawPressableButton.swift
//  winston
//
//  Created by Igor Marcossi on 01/01/24.
//

import SwiftUI

struct PressableButton<T: View>: View {
  @State private var pressed = false
  
  var animation: Animation? = .bouncy(duration: 0.325, extraBounce: 0.25)
  var action: () -> ()
  @ViewBuilder var label: (Bool) -> T
  
  var body: some View {
    label(pressed)
      .onTapGesture {
        action()
      }
      .onLongPressGesture(minimumDuration: 0.3, perform: { }, onPressingChanged: { val in
        withAnimation(animation) {
          pressed = val
        }
      })
  }
}
