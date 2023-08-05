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
  var url: String
  var media: Either<SecureMediaRedditVideo, SecureMediaAlt>
  var contentWidth: CGFloat
  @Default(.openYoutubeApp) var openYoutubeApp
  @Environment(\.openURL) var openURL
  var body: some View {
    switch media {
    case .second(let data):
      if let oembed = data.oembed, let width = oembed.width, let height = oembed.height, let ytURL = URL(string: url) {
        let actualHeight = (contentWidth * CGFloat(height)) / CGFloat(width)
        YouTubePlayerView(player)
          .frame(width: contentWidth, height: actualHeight)
          .mask(RR(12, .black))
          .allowsHitTesting(!openYoutubeApp)
          .contentShape(Rectangle())
          .highPriorityGesture(!openYoutubeApp ? TapGesture().onEnded { } : TapGesture().onEnded { openURL(ytURL) })
      }
    default:
     EmptyView()
    }
  }
}
