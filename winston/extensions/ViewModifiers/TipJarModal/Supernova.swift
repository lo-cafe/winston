//
//  Supernova.swift
//  winston
//
//  Created by Igor Marcossi on 23/03/24.
//

import SwiftUI
import CoreHaptics

private let floatingDuration = 3.0

struct Supernova: View {
  var shootComet: () -> Bool
  @State private var player = AVLooperPlayer(url: Bundle.main.url(forResource: "supernova", withExtension: "mp4")!)
  @State private var timer = Timer.publish(every: floatingDuration, on: .current, in: .common).autoconnect()
  @State private var offset: Double = 0
  @State private var life: Double = 7.0
  @State private var ahapPattern: CHHapticPattern? = nil
  var body: some View {
    let interpolate = interpolatorBuilder([7.0, 0.0], value: life)
    let multiplier = interpolate([1, 1.5], false)
    PPlayer(player: self.player)
      .frame(240 * multiplier)
      .mask { Circle().fill(.black).frame(200 * multiplier).blur(radius: 9.5 * multiplier) }
      .frame(198 * multiplier)
      .background {
        Circle().fill(
          Color.hex("F7FAFC")
            .shadow(.drop(color: Color.hex("E4EEFF").opacity(0.5), radius: 12 * multiplier))
            .shadow(.drop(color: Color.hex("D4E5FF").opacity(0.75), radius: 20 * multiplier))
            .shadow(.drop(color: Color.hex("BCD6FF").opacity(0.75), radius: 40 * multiplier))
            .shadow(.drop(color: Color.hex("85B0F6").opacity(0.5), radius: 80 * multiplier))
            .shadow(.drop(color: Color.hex("639CF8").opacity(1.0), radius: 120 * multiplier))
            .shadow(.drop(color: Color.hex("72A6F9").opacity(0.25), radius: 200 * multiplier))
        )
        .blur(radius: 4.25 * multiplier)
      }
      .allowsHitTesting(false)
      .contentShape(Circle())
      .onTapGesture {
        if shootComet(), let ahapPattern {
          if life == 1 { Hap.shared.play(intensity: 1, sharpness: 0) } else {
            Hap.shared.playPattern(ahapPattern)
            withAnimation(.easeInOut(duration: 3)) { life -= 1 }
          }
        }
      }
      .offset(y: offset)
      .task {
        player.play()
        ahapPattern = try? CHHapticPattern(contentsOf: Bundle.main.url(forResource: "supernova", withExtension: "ahap")!)
      }
      .onReceive(timer) { _ in
        withAnimation(.easeInOut(duration: floatingDuration)) {
          offset = offset == 0 ? CGFloat.random(in: 2...5) : 0
        }
      }
      .brightness(0.35)
  }
}

