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
      if let oembed = data.oembed, let width = oembed.width, let height = oembed.height {
        let actualHeight = (contentWidth * CGFloat(height)) / CGFloat(width)
        YouTubePlayerView(player)
          .frame(width: contentWidth, height: actualHeight)
          .mask(RR(12, .black))
          .highPriorityGesture( TapGesture().onEnded { } )
          .if(openYoutubeApp) {
            $0.allowsHitTesting(false).contentShape(Rectangle()).highPriorityGesture( TapGesture().onEnded { openURL(URL(string: url)!) } )
          }
          .if(!openYoutubeApp) {
            $0.highPriorityGesture( TapGesture().onEnded { } )
          }
      }
    default:
     EmptyView()
    }
  }
}
