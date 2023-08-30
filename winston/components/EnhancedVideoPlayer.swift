////
////  EnhancedVideoPlayer.swift
////  winston
////
////  Created by Igor Marcossi on 30/08/23.
////
//
//import SwiftUI
//import Defaults
//import CoreMedia
//import AVKit
//import AVFoundation
//
//struct EnhancedVideoPlayer<VideoOverlay: View>: View {
//  @StateObject private var viewModel: ViewModel
//  @ViewBuilder var videoOverlay: () -> VideoOverlay
//
//  init(_ urls: [URL],
//       endAction: EndAction = .none,
//       @ViewBuilder videoOverlay: @escaping () -> VideoOverlay) {
//    _viewModel = StateObject(wrappedValue: ViewModel(urls: urls, endAction: endAction))
//    self.videoOverlay = videoOverlay
//  }
//
//  var body: some View {
//    VideoPlayer(player: viewModel.player, videoOverlay: videoOverlay)
//  }
//
//  class ViewModel: ObservableObject {
//    let player: AVQueuePlayer
//
//    init(urls: [URL], endAction: EndAction) {
//      let playerItems = urls.map { AVPlayerItem(url: $0) }
//      player = AVQueuePlayer(items: playerItems)
//      player.actionAtItemEnd = .none // we'll manually set which video comes next in playback
//      if endAction != .none {
//        // this notification is triggered whenever a player item finishes playing
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
//                                               object: nil,
//                                               queue: nil) { [self] notification in
//          let currentItem = notification.object as? AVPlayerItem
//          if endAction == .loop,
//             let currentItem = currentItem {
//            player.seek(to: .zero) // set the current player item to beginning
//            player.advanceToNextItem() // move to next video manually
//            player.insert(currentItem, after: nil) // add it to the end of the queue
//          }
//        }
//      }
//    }
//  }
//
//  enum EndAction: Equatable {
//    case none,
//         loop
//}
//
//extension EnhancedVideoPlayer where VideoOverlay == EmptyView {
//  init(_ urls: [URL], endAction: EndAction) {
//    self.init(urls, endAction: endAction) {
//      EmptyView()
//    }
//  }
//}
