//
//  PreviewYTLink.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import Foundation
import SwiftUI
import YouTubePlayerKit
import Defaults

struct PreviewYTLink: View {
  @StateObject var player: YouTubePlayer
  var videoID: String
  var size: CGSize
  var contentWidth: CGFloat
  @Default(.openYoutubeApp) var openYoutubeApp
  @Environment(\.openURL) var openURL
  var body: some View {
    if let ytURL = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
        let width = size.width
        let height = size.height
        let actualHeight = (contentWidth * CGFloat(height)) / CGFloat(width)
        YouTubePlayerView(player)
          .frame(width: contentWidth, height: actualHeight)
          .mask(RR(12, .black))
          .allowsHitTesting(!openYoutubeApp)
          .contentShape(Rectangle())
          .highPriorityGesture(TapGesture().onEnded { if openYoutubeApp { openURL(ytURL) } })
      }
  }
}
