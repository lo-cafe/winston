//
//  LightBoxElementView2.swift
//  winston
//
//  Created by Daniel Inama on 26/08/23.
//

import SwiftUI
import NukeUI

struct LightBoxElementView2: View {
  var el: MediaExtracted
  var onTap: (()->())?
  @Binding var isPinching: Bool
  var doLiveText: Bool = false
  @State private var scale: CGFloat = 1.0
  @State private var anchor: UnitPoint = .zero
  @State private var offset: CGSize = .zero
  var body: some View {
    URLImage(url: el.url, doLiveText: doLiveText)
      .scaledToFit()
      .pinchToZoom(onTap: onTap, size: el.size, isPinching: $isPinching, scale: $scale, anchor: $anchor, offset: $offset)
      .id(el.id)
  }
}
