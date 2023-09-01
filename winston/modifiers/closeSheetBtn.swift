//
//  closeSheetBtn.swift
//  winston
//
//  Created by Igor Marcossi on 31/08/23.
//

import SwiftUI

extension View {
  func closeSheetBtn(_ action: @escaping ()->()) -> some View {
    self
      .overlay(
        Button(action: action) {
          Image(systemName: "xmark.circle.fill")
            .fontSize(24)
            .opacity(0.5)
        }
          .buttonStyle(.plain)
          .padding(.all, 16)
        , alignment: .topTrailing
      )
  }
}
