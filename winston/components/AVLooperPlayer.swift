//
//  AVLooperPlayer.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import Foundation
import AVKit

class AVLooperPlayer: AVQueuePlayer {
  private var looper: AVPlayerLooper!
  
  func togglePlaying() { if self.isPlaying { self.pause() } else { self.play() } }
  
  convenience override init(url: URL) {
    let playerItem = AVPlayerItem(url: url)
    self.init(playerItem: playerItem)
    looper = AVPlayerLooper(player: self, templateItem: playerItem)
  }
}
