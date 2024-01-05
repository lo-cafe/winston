//
//  BetterLottieView.swift
//  winston
//
//  Created by Igor Marcossi on 03/01/24.
//

import SwiftUI
import Lottie

struct BetterLottieView: View {
  let animationName: String
  let size: Double
  let loopDelay: Double?
  let initialDelay: Double
  let color: Color
  let animationSupportsSwitching: Bool
  
  @State private var playbackMode: LottiePlaybackMode = .paused(at: .time(0))
  @State private var actualAnimationName: String
  @State private var waitingForSwitching = false
  @State private var firstAppear = true
  @State private var id = UUID().uuidString
  
  init(_ animationName: String, size: Double, loopDelay: Double? = nil, initialDelay: Double = 0, color: Color = .accentColor, animationSupportsSwitching: Bool = false) {
    self.animationName = animationName
    self.size = size
    self._actualAnimationName = .init(initialValue: animationName)
    self.loopDelay = loopDelay
    self.initialDelay = initialDelay
    self.color = color
    self.animationSupportsSwitching = animationSupportsSwitching
  }
  
  var body: some View {
    let rgb = UIColor(color).rgb
    let colorProvider = ColorValueProvider(.init(r: rgb.0, g: rgb.1, b: rgb.2, a: color.alpha))
    
    LottieView(animation: .named(animationName))
      .playbackMode(playbackMode)
      .valueProvider(colorProvider, for: colorLottieKeypath)
      .configuration(.init(renderingEngine: .coreAnimation))
      .animationDidLoad({ src in
        if firstAppear {
          doThisAfter(initialDelay) {
            playbackMode = .playing(.toProgress(1, loopMode: .playOnce))
          }
        }
      })
      .animationDidFinish({ completed in
        guard completed else { return }
        if waitingForSwitching {
          waitingForSwitching = false
          playbackMode = .paused(at: .time(0))
          actualAnimationName = animationName
          playbackMode = .playing(.toProgress(1, loopMode: .playOnce))
        } else if let loopDelay {
          if loopDelay == 0 {
            playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
          } else {
            doThisAfter(loopDelay) { playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)) }
          }
        }
      })
      .frame(size)
      .transition(animationSupportsSwitching ? .identity : .scaleAndBlur)
      .id("\(id)-\(actualAnimationName)")
      .onChange(of: animationName) { newAnimName in
        if animationSupportsSwitching {
          waitingForSwitching = true
          playbackMode = .playing(.toProgress(0, loopMode: .playOnce))
        } else {
          playbackMode = .paused(at: .time(0))
          withAnimation(.spring) {
            actualAnimationName = newAnimName
          }
          doThisAfter(0.4) {
            playbackMode = .playing(.toProgress(1, loopMode: .playOnce))
          }
        }
      }
      .onAppear {
        doThisAfter(0.315) {
          playbackMode = .playing(.toProgress(1, loopMode: .playOnce))
        }
      }
  }
}
