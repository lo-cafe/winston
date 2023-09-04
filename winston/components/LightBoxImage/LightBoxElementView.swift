//
//  LightBoxElementView.swift
//  winston
//
//  Created by Igor Marcossi on 07/08/23.
//

import SwiftUI
import NukeUI

struct LightBoxElement: Identifiable, Equatable {
  var url: String
  var size: CGSize
  var id: String { self.url }
}

struct LightBoxElementView: View {
  var el: MediaExtracted
  var onTap: (()->())?
  @Binding var isPinching: Bool
  @State private var scale: CGFloat = 1.0
  @State private var anchor: UnitPoint = .center
  @State private var offset: CGSize = .zero
  @State private var altSize: CGSize = .zero
  var body: some View {
    URLImage(url: el.url)
    .scaledToFit()
    .background(
      el.size != .zero
      ? nil
      : GeometryReader { geo in
        Color.clear
          .onAppear { altSize = geo.size }
          .onChange(of: geo.size) { newValue in altSize = newValue }
      }
    )
    .pinchToZoom(onTap: onTap, size: el.size == .zero ? altSize : el.size, isPinching: $isPinching, scale: $scale, anchor: $anchor, offset: $offset)
    .id("\(el.id)\(altSize.width + altSize.height)")
  }
}
