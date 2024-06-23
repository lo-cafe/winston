//
//  AccountSwitcherParticles.swift
//  winston
//
//  Created by Igor Marcossi on 28/11/23.
//

import SwiftUI
import SpriteKit
import AVKit

//let dustScene = DustScene(size: .init(width: .screenW, height: .screenH))

struct AccountSwitcherParticles: View, Equatable {
  static var player = AVLooperPlayer(url: Bundle.main.url(forResource: "particle", withExtension: "mov")!)
//  static var player = AVLooperPlayer(url: Bundle.main.url(forResource: "space", withExtension: "mov")!)
  
  static func == (lhs: AccountSwitcherParticles, rhs: AccountSwitcherParticles) -> Bool { true }
  //  @State var player = AVPlayer(url: Bundle.main.url(forResource: "particles-1", withExtension: "mp4")!)
  var body: some View {
//    GeometryReader { proxy in
    PPlayer(player: Self.player)
        .frame(.screenSize,  .bottom)
        .task { Self.player.play() }
        .onDisappear {
          let time = CMTime(seconds: Double(arc4random_uniform(16)), preferredTimescale: 1) // Random time between 0 and 15 seconds
          Self.player.seek(to: time)
          Self.player.pause()
        }
        .mask(Rectangle().fill(EllipticalGradient(colors: [.black, .black.opacity(0)], center: .bottom, startRadiusFraction: 0, endRadiusFraction: 0.75)))
        .blendMode(.screen)
//    }
  }
}


struct PPlayer: UIViewRepresentable {
  var player: AVPlayer
  var gravity: AVLayerVideoGravity = .resizeAspectFill

  func makeUIView(context: Context) -> UIView {
    let view = PlayerView()
    view.player = self.player
    view.playerLayer.videoGravity = gravity
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    return view
  }

  func updateUIView(_ view: UIView, context: Context) { }

  class PlayerView: UIView {
      override static var layerClass: AnyClass { AVPlayerLayer.self }
      
      var player: AVPlayer? {
          get { playerLayer.player }
          set { playerLayer.player = newValue }
      }
      
      var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
  }
}
