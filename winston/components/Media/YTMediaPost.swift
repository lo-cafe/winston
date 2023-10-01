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

struct YTMediaPost: View, Equatable {
  static func == (lhs: YTMediaPost, rhs: YTMediaPost) -> Bool {
    lhs.videoID == rhs.videoID
  }
  
  @ObservedObject private var playersCache = Caches.ytPlayers
  var compact: Bool
  var videoID: String
  var size: CGSize
  var contentWidth: CGFloat
  @Default(.openYoutubeApp) private var openYoutubeApp
  @Environment(\.openURL) private var openURL
  
  var body: some View {
    let actualHeight = (contentWidth * CGFloat(size.height)) / CGFloat(size.width)
    if let cached = playersCache.cache[videoID]?.data {
      YTMediaPostPlayer(compact: compact, player: cached.player, ytMediaExtracted: cached, contentWidth: contentWidth, openYoutubeApp: openYoutubeApp, openURL: openURL)
    } else {
      ProgressView()
        .frame(width: contentWidth, height: actualHeight)
    }
  }
}

struct YTMediaPostPlayer: View, Equatable {
  static func == (lhs: YTMediaPostPlayer, rhs: YTMediaPostPlayer) -> Bool {
    lhs.ytMediaExtracted.id == rhs.ytMediaExtracted.id
  }
  var compact: Bool
  var player: YouTubePlayer
  var ytMediaExtracted: YTMediaExtracted
  var contentWidth: CGFloat
  var openYoutubeApp: Bool
  var openURL: OpenURLAction
  @State private var showPlayer = false
  
  var body: some View {
    let actualHeight = (contentWidth * CGFloat(ytMediaExtracted.size.height)) / CGFloat(ytMediaExtracted.size.width)
    
    Group {
      if !showPlayer {
        ZStack {
          URLImage(url: ytMediaExtracted.thumbnailURL, imgRequest: ytMediaExtracted.thumbnailRequest)
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


