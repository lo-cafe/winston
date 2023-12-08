//
//  AccountSwitcherParticles.swift
//  winston
//
//  Created by Igor Marcossi on 28/11/23.
//

import SwiftUI
import SpriteKit
import AVKit

//let dustScene = DustScene(size: .init(width: UIScreen.screenWidth, height: UIScreen.screenHeight))

struct AccountSwitcherParticles: View, Equatable {
  static var player = AVLooperPlayer(url: Bundle.main.url(forResource: "particle", withExtension: "mov")!)
//  static var player = AVLooperPlayer(url: Bundle.main.url(forResource: "space", withExtension: "mov")!)
  
  static func == (lhs: AccountSwitcherParticles, rhs: AccountSwitcherParticles) -> Bool { true }
  //  @State var player = AVPlayer(url: Bundle.main.url(forResource: "particles-1", withExtension: "mp4")!)
  @State private var blur = true
  var body: some View {
//    GeometryReader { proxy in
    PPlayer(player: Self.player)
        .frame(.screenSize,  .bottom)
        .onAppear {
          withAnimation(.easeOut) { blur = false }
          Self.player.play()
        }
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

  func makeUIView(context: Context) -> UIView {
    let view = PlayerView()
//    view.playerLayer.frame = CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.width)
    let rotationDegrees: CGFloat = 90.0
    let rotationRadians: CGFloat = (rotationDegrees * .pi) / 180.0
    view.playerLayer.setAffineTransform(CGAffineTransform.identity.rotated(by: rotationRadians))

    view.player = self.player
    view.playerLayer.videoGravity = .resizeAspectFill
//    view.playerLayer.setAffineTransform(CGAffineTransform(scaleX: 1, y: -1))
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    return view
  }

  func updateUIView(_ view: UIView, context: Context) { }

  class PlayerView: UIView {
      // Override the property to make AVPlayerLayer the view's backing layer.
      override static var layerClass: AnyClass { AVPlayerLayer.self }
      
      // The associated player object.
      var player: AVPlayer? {
          get { playerLayer.player }
          set { playerLayer.player = newValue }
      }
      
      var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
//    init() {
//      super.init()
//      self.playerLayer.videoGravity = .resizeAspectFill
//      self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    }
//    
//    required init?(coder: NSCoder) {
//      fatalError("init(coder:) has not been implemented")
//    }
  }
}
