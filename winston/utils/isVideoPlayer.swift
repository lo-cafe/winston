//
//  isVideoPlayer.swift
//  winston
//
//  Created by Igor Marcossi on 31/07/23.
//

import Foundation
import AVKit

extension AVPlayer {
        var isPlaying: Bool { self.timeControlStatus == AVPlayer.TimeControlStatus.playing }
}
