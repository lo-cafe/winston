//
//  Onboarding.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import SwiftUI

struct Onboarding: View {
  @State private var currentTab = 0
  
  var body: some View {
    TabView(selection: $currentTab) {
      Text("First View")
        .simultaneousGesture(DragGesture())
        .tag(0)
      Text("Second View")
        .tag(1)
      Text("Third View")
        .tag(2)
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
  }
}
