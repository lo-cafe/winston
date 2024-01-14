//
//  ImageSize.swift
//  winston
//
//  Created by Igor Marcossi on 30/12/23.
//

import SwiftUI

extension Image {
  func size(_ size: Double, _ contentMode: ContentMode = .fit) -> some View {
    self.resizable().aspectRatio(contentMode: contentMode).frame(size)
  }
  func maxHeight(_ height: Double, _ contentMode: ContentMode = .fit) -> some View {
    self.resizable().aspectRatio(contentMode: contentMode).frame(height: height)
  }
  func maxWidth(_ width: Double, _ contentMode: ContentMode = .fit) -> some View {
    self.resizable().aspectRatio(contentMode: contentMode).frame(width: width)
  }
  func asFontSize(_ fontSize: Double = 16, _ contentMode: ContentMode = .fit) -> some View {
    self.resizable().aspectRatio(contentMode: contentMode).frame(height: fontSize * 1.2)
  }
}
