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

class YTPlayersCache: ObservableObject {
  struct CacheItem {
    let player: YouTubePlayer
    let date: Date
  }
  
  static var shared = YTPlayersCache()
  @Published var cache: [String: CacheItem] = [:]
  let cacheLimit = 35
  
  func addKeyValue(key: String, player: YouTubePlayer) {
    if !cache[key].isNil { return }
    Task(priority: .background) {
      // Create a new CacheItem with the current date
      let item = CacheItem(player: player, date: Date())
      let oldestKey = cache.count > cacheLimit ? cache.min { a, b in a.value.date < b.value.date }?.key : nil
      
      // Add the item to the cache
      await MainActor.run {
        withAnimation {
          cache[key] = item
          if let oldestKey = oldestKey { cache.removeValue(forKey: oldestKey) }
        }
      }
    }
  }
  
  private let _objectWillChange = PassthroughSubject<Void, Never>()
  
  var objectWillChange: AnyPublisher<Void, Never> { _objectWillChange.eraseToAnyPublisher() }
  
  subscript(key: String) -> CacheItem? {
    get { cache[key] }
    set {
      cache[key] = newValue
      _objectWillChange.send()
    }
  }
  
  func merge(_ dict: [String:CacheItem]) {
    cache.merge(dict) { (_, new) in new }
    _objectWillChange.send()
  }
}

struct PreviewYTLink: View, Equatable {
  static func == (lhs: PreviewYTLink, rhs: PreviewYTLink) -> Bool {
    lhs.videoID == rhs.videoID
  }
  
  @ObservedObject private var playersCache = YTPlayersCache.shared
  var videoID: String
  var size: CGSize
  var contentWidth: CGFloat
  @Default(.openYoutubeApp) private var openYoutubeApp
  @Environment(\.openURL) private var openURL
  
  init(videoID: String, size: CGSize, contentWidth: CGFloat) {
    self.videoID = videoID
    self.size = size
    self.contentWidth = contentWidth
    YTPlayersCache.shared.addKeyValue(key: videoID, player: YouTubePlayer(source: .video(id: videoID)))
  }
  
  var body: some View {
    let actualHeight = (contentWidth * CGFloat(size.height)) / CGFloat(size.width)
    if let player = playersCache[videoID]?.player {
      YouTubePlayerView(player)
        .frame(width: contentWidth, height: actualHeight)
        .mask(RR(12, .black))
        .allowsHitTesting(!openYoutubeApp)
        .contentShape(Rectangle())
        .highPriorityGesture(TapGesture().onEnded { if openYoutubeApp { openURL(URL(string: "https://www.youtube.com/watch?v=\(videoID)")!) } })
    }
  }
}
