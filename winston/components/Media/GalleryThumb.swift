//
//  GalleryThumb.swift
//  winston
//
//  Created by Igor Marcossi on 22/08/23.
//

import SwiftUI

struct GalleryThumb: View {
  var ns: Namespace.ID
  var width: CGFloat
  var height: CGFloat?
  @State private var altHeight: CGFloat?
  var url: URL
  var body: some View {
    URLImage(url: url, processors: [.resize(width: width)])
    .scaledToFill()
    .zIndex(1)
    .allowsHitTesting(false)
    .fixedSize(horizontal: false, vertical: height.isNil)
    .background(
      !height.isNil
      ? nil
      : GeometryReader { geo in
        Color.clear
          .onAppear { altHeight = geo.size.height }
          .onChange(of: geo.size) { newValue in altHeight = newValue.height }
      }
    )
    .frame(width: width, height: height ?? altHeight ?? 100)
    .clipped()
    .mask(RR(12, .black))
    .contentShape(Rectangle())
  }
}
