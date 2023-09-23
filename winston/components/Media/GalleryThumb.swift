//
//  GalleryThumb.swift
//  winston
//
//  Created by Igor Marcossi on 22/08/23.
//

import SwiftUI
import Defaults

struct GalleryThumb: View, Equatable {
  static func == (lhs: GalleryThumb, rhs: GalleryThumb) -> Bool {
    lhs.width == rhs.width && lhs.url == rhs.url
  }
  
  var width: CGFloat
  var height: CGFloat?
  @Environment(\.useTheme) private var selectedTheme
  
  var url: URL
  var body: some View {
    URLImage(url: url, processors: [.resize(width: width)])
      .equatable()
      .scaledToFill()
      .zIndex(1)
      .allowsHitTesting(false)
      .fixedSize(horizontal: false, vertical: height.isNil)
      .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
      .clipped()
      .mask(RR(selectedTheme.postLinks.theme.mediaCornerRadius, Color.black))
      .contentShape(Rectangle())
  }
}
