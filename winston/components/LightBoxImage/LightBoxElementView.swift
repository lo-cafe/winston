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
  var el: LightBoxElement
  var onTap: (()->())?
  @Binding var isPinching: Bool
  @State private var scale: CGFloat = 1.0
  @State private var anchor: UnitPoint = .zero
  @State private var offset: CGSize = .zero
  var body: some View {
    URLImage(url: URL(string: el.url)!)
    .scaledToFit()
    .pinchToZoom(onTap: onTap, size: el.size, isPinching: $isPinching, scale: $scale, anchor: $anchor, offset: $offset)
    .id(el.id)
  }
}
