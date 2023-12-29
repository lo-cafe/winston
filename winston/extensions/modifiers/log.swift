//
//  print.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import SwiftUI

extension View {
  func log(_ items: Any...) -> some View {
    self
      .onAppear {
        print(items)
      }
  }
}
