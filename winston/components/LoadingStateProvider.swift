//
//  LoadingStateProvider.swift
//  winston
//
//  Created by Igor Marcossi on 14/02/24.
//

import SwiftUI

struct LoadingStateProvider<C: View>: View {
  @State private var loading = false
  
  @ViewBuilder var content: (Bool, ((Bool) -> ())) -> C
  
  func toggle(_ val: Bool? = nil) {
    loading = val ?? !loading
  }
    var body: some View {
      content(loading, toggle)
    }
}
