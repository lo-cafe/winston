//
//  GalleryThumb.swift
//  winston
//
//  Created by Igor Marcossi on 22/08/23.
//

import SwiftUI
import Defaults
import Nuke

struct GalleryThumb: View, Equatable {
  static func == (lhs: GalleryThumb, rhs: GalleryThumb) -> Bool {
    lhs.url == rhs.url && lhs.width == rhs.width && lhs.height == rhs.height && lhs.cornerRadius == rhs.cornerRadius
  }
  
  var cornerRadius: Double
  var width: CGFloat
  var height: CGFloat?
  var url: URL
  var imgRequest: ImageRequest? = nil
  
//  @Environment(\.useTheme) private var selectedTheme
  
  var body: some View {
    URLImage(url: url, imgRequest: imgRequest, processors: [.resize(width: width)], size: CGSize(width: width, height: height ?? 0))
            .scaledToFit()
      .zIndex(1)
      .fixedSize(horizontal: false, vertical: height == nil)
      .allowsHitTesting(false)
      .frame(width: width, height: height)
      .mask(RR(cornerRadius, Color.black).equatable())
      .contentShape(Rectangle())
  }
}
