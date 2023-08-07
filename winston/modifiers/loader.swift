//
//  ListLoader.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI

extension View {
  func loader(_ loading: Bool, _ onAppear: (()->())? = nil) -> some View {
    self
      .overlay(
        !loading
        ? nil
        : ProgressView()
          .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
          .ignoresSafeArea()
          .onAppear { onAppear?() }
      )
    }
}
