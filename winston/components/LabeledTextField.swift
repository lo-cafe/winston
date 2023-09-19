//
//  LabeledTextField.swift
//  winston
//
//  Created by Igor Marcossi on 09/09/23.
//

import SwiftUI

struct LabeledTextField: View {
  var label: String
  @Binding var text: String
  @FocusState private var focused: Bool
  
  init(_ label: String, _ text: Binding<String>) {
    self.label = label
    self._text = text
  }
  var body: some View {
    HStack {
      Text(label)
      Spacer()
        .frame(maxWidth: .infinity)
      TextField("", text: $text)
        .focused($focused)
        .multilineTextAlignment(.trailing)
        .opacity(focused ? 1 : 0.5)
    }
    .frame(maxWidth: .infinity)
  }
}

