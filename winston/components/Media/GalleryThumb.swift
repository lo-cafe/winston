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
  var height: CGFloat
  var url: URL
  var body: some View {
    URLImage(url: url, processors: [.resize(width: width)])
    .scaledToFill()
    .zIndex(1)
    .allowsHitTesting(false)
    .frame(width: width, height: height)
    .clipped()
    .mask(RR(12, .black))
    .contentShape(Rectangle())
  }
}
