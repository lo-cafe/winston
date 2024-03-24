//
//  Blackhole.swift
//  winston
//
//  Created by Igor Marcossi on 24/03/24.
//

import SwiftUI
import CoreHaptics

private let floatingDuration = 3.0

struct Blackhole: View {
  @State private var timer = Timer.publish(every: floatingDuration, on: .current, in: .common).autoconnect()
  @State private var player = AVLooperPlayer(url: Bundle.main.url(forResource: "blackhole", withExtension: "mp4")!)
  @State private var offset: Double = 0
  @State private var begin = false
  var body: some View {
    PPlayer(player: self.player, gravity: .resizeAspect)
      .frame(width: 640, height: 360)
      .blendMode(.screen)
      .background { Circle().fill(.black).frame(250).blur(radius: 30) }
      .scaleEffect(begin ? 1 : 0.01)
      .opacity(begin ? 1 : 0)
      .zIndex(-1)
      .onAppear {
        if let ahapPattern = try? CHHapticPattern(contentsOf: Bundle.main.url(forResource: "blackhole", withExtension: "ahap")!) {
          Hap.shared.playPattern(ahapPattern)
        }
        doThisAfter(1.285) {
          player.play()
          withAnimation(.spring(response: 1, dampingFraction: 1.5)) {
            begin = true
          }
        }
      }
      .onReceive(timer) { _ in
        withAnimation(.easeInOut(duration: floatingDuration)) {
          offset = offset == 0 ? CGFloat.random(in: 2...5) : 0
        }
      }
  }
}

