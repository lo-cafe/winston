//
//  SpoilerModifer.swift
//  winston
//
//  Created by daniel on 22/11/23.
//

import SwiftUI

struct SpoilerModifer: ViewModifier {
  @State var pixelate = 20.0
  
  func body(content: Content) -> some View {
    
    content
      .ifIOS17{ content in
        if #available(iOS 17.0, *) {
          content
            .distortionEffect(
              .init(
                function: .init(library: .default, name: "pixelate"),
                arguments: [.float(pixelate)]),
              maxSampleOffset: .zero
            )
        }
      }
      .highPriorityGesture(TapGesture().onEnded{
        pixelate = 0.0
      })
  }
  
}

extension View {
  func spoiler() -> some View {
    self.modifier(SpoilerModifer())
  }
}
