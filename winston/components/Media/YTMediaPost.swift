//
//  YTMediaPost.swift
//  winston
//
//  Created by Igor Marcossi on 30/07/23.
//

import Foundation
import SwiftUI
import YouTubePlayerKit
import Defaults
import Combine

struct YTMediaPostPlayer: View, Equatable {
  static func == (lhs: YTMediaPostPlayer, rhs: YTMediaPostPlayer) -> Bool {
    lhs.ytMediaExtracted.id == rhs.ytMediaExtracted.id
  }
  var compact: Bool
  var player: YouTubePlayer
  var ytMediaExtracted: YTMediaExtracted
  var contentWidth: CGFloat
  @Default(.BehaviorDefSettings) private var behaviorDefSettings
  @Environment(\.openURL) private var openURL
  @State private var showPlayer = false
  
  var body: some View {
    let openYoutubeApp = behaviorDefSettings.openYoutubeApp
    let actualHeight = (contentWidth * CGFloat(ytMediaExtracted.size.height)) / CGFloat(ytMediaExtracted.size.width)
    
    Group {
      if !showPlayer {
        ZStack {
          URLImage(url: ytMediaExtracted.thumbnailURL, doLiveText: false, imgRequest: ytMediaExtracted.thumbnailRequest)
            .scaledToFill()
          Image(systemName: "play.circle.fill").fontSize(compact ? 22 : 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        YouTubePlayerView(player)
      }
    }
    .frame(width: compact ? scaledCompactModeThumbSize() : contentWidth, height: compact ? scaledCompactModeThumbSize() : actualHeight)
    .mask(RR(12, Color.black))
    .allowsHitTesting(!openYoutubeApp)
    .contentShape(Rectangle())
    .highPriorityGesture(!openYoutubeApp && showPlayer ? nil : TapGesture().onEnded {
      if openYoutubeApp || compact {
        openURL(URL(string: "https://www.youtube.com/watch?v=\(ytMediaExtracted.videoID)")!)
      } else {
        withAnimation { showPlayer = true }
      }
    })
    .onDisappear {
      showPlayer = false
    }
  }
}


