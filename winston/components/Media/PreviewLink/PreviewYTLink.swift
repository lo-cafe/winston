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
import Combine

struct PreviewYTLink: View, Equatable {
  static func == (lhs: PreviewYTLink, rhs: PreviewYTLink) -> Bool {
    lhs.videoID == rhs.videoID
  }
  
  @ObservedObject private var playersCache = Caches.ytPlayers
  var videoID: String
  var size: CGSize
  var contentWidth: CGFloat
  @Default(.openYoutubeApp) private var openYoutubeApp
  @Environment(\.openURL) private var openURL
  
  init(videoID: String, size: CGSize, contentWidth: CGFloat) {
    self.videoID = videoID
    self.size = size
    self.contentWidth = contentWidth
    Caches.ytPlayers.addKeyValue(key: videoID, data: { YouTubePlayer(source: .video(id: videoID)) } )
  }
  
  var body: some View {
    let actualHeight = (contentWidth * CGFloat(size.height)) / CGFloat(size.width)
    if let player = playersCache.cache[videoID]?.data {
      PreviewYTLinkPlayer(player: player, videoID: videoID, size: size, contentWidth: contentWidth)
    } else {
      ProgressView()
        .frame(width: contentWidth, height: actualHeight)
    }
  }
}

struct PreviewYTLinkPlayer: View, Equatable {
  static func == (lhs: PreviewYTLinkPlayer, rhs: PreviewYTLinkPlayer) -> Bool {
    lhs.videoID == rhs.videoID
  }
  
  @StateObject var player: YouTubePlayer
  var videoID: String
  var size: CGSize
  var contentWidth: CGFloat
  @Default(.openYoutubeApp) private var openYoutubeApp
  @Environment(\.openURL) private var openURL
  
  var body: some View {
    let actualHeight = (contentWidth * CGFloat(size.height)) / CGFloat(size.width)
    YouTubePlayerView(player)
      .frame(width: contentWidth, height: actualHeight)
      .mask(RR(12, Color.black))
      .allowsHitTesting(!openYoutubeApp)
      .contentShape(Rectangle())
      .highPriorityGesture(TapGesture().onEnded { if openYoutubeApp { openURL(URL(string: "https://www.youtube.com/watch?v=\(videoID)")!) } })
  }
}


