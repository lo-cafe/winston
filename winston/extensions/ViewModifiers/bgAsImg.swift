//
//  bgAsImg.swift
//  winston
//
//  Created by Igor Marcossi on 26/02/24.
//

import SwiftUI

struct BgAsImageModifier<Content: View>: View {
  var show: Bool
  @State private var active: Bool = false
  @State private var screenshot: UIImage? = nil
  
  @ViewBuilder let content: (Image, Bool) -> Content
  
  var body: some View {
    ZStack {
      if let screenshot {
        content(
          Image(uiImage: screenshot)
          , active)
        .background(.black)
        .transition(.identity)
        .onAppear { self.active = true }
      }
    }
    .onChange(of: show) { old, new in
      if old && !new {
        active = false
        screenshot = nil
      } else if !old && new {
        screenshot = takeScreenshotAndSave()
      }
    }
  }
}

extension View {
  func bgAsImg<Content: View>(
    show: Bool,
    @ViewBuilder _ content: @escaping (Image, Bool) -> Content
  ) -> some View where Content: View {
    self.background {
      GeometryReader { _ in
        BgAsImageModifier(show: show, content: content)
      }
      .ignoresSafeArea(.all)
    }
  }
}
