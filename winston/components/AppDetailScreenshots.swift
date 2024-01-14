//
//  AppDetailScreenshots.swift
//  winston
//
//  Created by Daniel Inama on 05/10/23.
//

import SwiftUI
import NukeUI

public struct AppDetailScreenshots: View {
  
  public static let maxHeight: CGFloat = 500
  
  let screenshots: [String]
  
  public init(screenshots: [String]) {
    self.screenshots = screenshots
  }
  
  
  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10){
        ForEach(screenshots, id:\.self){ screenshot in
          URLImage(url: URL(string: screenshot)!)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
            .scaledToFit()
            .frame(maxHeight: AppDetailScreenshots.maxHeight)
        }
      }
      .padding(.horizontal)
      .scrollViewContentRTLFriendly()
    }
    .frame(height: galleryHeight)
    .scrollViewRTLFriendly()
    .scrollTargetBehavior(.paging)
  }
  
  private var galleryHeight: CGFloat {
    Self.maxHeight
  }
}

