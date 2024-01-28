//
//  BetterLottieView.swift
//  winston
//
//  Created by Igor Marcossi on 03/01/24.
//

import SwiftUI
import Lottie

struct StillLottieView: View {
  var animationName: String
  var size: Double
  var color: Color
  var progress: Double
  
  init(_ animationName: String, fontSize: Double = 16, color: Color = .primary, progress: Double = 1) {
    self.animationName = animationName
    self.size = fontSize * 1.2
    self.color = color
    self.progress = progress
  }
  
  var body: some View {
    let actualColor = color
    let rgb = UIColor(actualColor).rgb
    let colorProvider = ColorValueProvider(.init(r: rgb.0, g: rgb.1, b: rgb.2, a: actualColor.alpha))
    
    LottieView(animation: .named(animationName))
      .playbackMode(.paused(at: .progress(progress)))
      .valueProvider(colorProvider, for: colorLottieKeypath)
      .configure { v in
        v.configuration = .init(renderingEngine: .coreAnimation)
        v.shouldRasterizeWhenIdle = true
      }
      .resizable()
      .frame(size)
  }
}

struct BetterLottieView: View {
  let animationName: String
  let size: CGSize
  let loopDelay: Double?
  let initialDelay: Double
  let skipInitialProgress: Double
  let color: Color?
  let animationSupportsSwitching: Bool
  let contentMode: ContentMode
  
  @State private var playbackMode: LottiePlaybackMode
  @State private var actualAnimationName: String
  @State private var waitingForSwitching = false
  @State private var firstAppear = true
  @State private var id = UUID().uuidString
  
  init(_ animationName: String, size: Double, loopDelay: Double? = nil, initialDelay: Double = 0, skipInitialProgress: Double = 0, color: Color? = .accentColor, animationSupportsSwitching: Bool = false, contentMode: ContentMode = .fit) {
    self.animationName = animationName
    self.size = .init(width: size, height: size)
    self._playbackMode = .init(initialValue: .paused(at: .progress(skipInitialProgress)))
    self._actualAnimationName = .init(initialValue: animationName)
    self.loopDelay = loopDelay
    self.skipInitialProgress = skipInitialProgress
    self.initialDelay = initialDelay
    self.color = color
    self.animationSupportsSwitching = animationSupportsSwitching
    self.contentMode = contentMode
  }
  
  init(_ animationName: String, size: CGSize, loopDelay: Double? = nil, initialDelay: Double = 0, skipInitialProgress: Double = 0, color: Color? = .accentColor, animationSupportsSwitching: Bool = false, contentMode: ContentMode = .fit) {
    self.animationName = animationName
    self.size = size
    self._playbackMode = .init(initialValue: .paused(at: .progress(skipInitialProgress))) 
    self._actualAnimationName = .init(initialValue: animationName)
    self.loopDelay = loopDelay
    self.skipInitialProgress = skipInitialProgress
    self.initialDelay = initialDelay
    self.color = color
    self.animationSupportsSwitching = animationSupportsSwitching
    self.contentMode = contentMode
  }
  
  var body: some View {
    let actualColor = color ?? .white
    let rgb = UIColor(actualColor).rgb
    let colorProvider = ColorValueProvider(.init(r: rgb.0, g: rgb.1, b: rgb.2, a: actualColor.alpha))
    
    LottieView(animation: .named(animationName))
      .playbackMode(playbackMode)
      .valueProvider(colorProvider, for: color == nil ? emptyColorLottieKeypath : colorLottieKeypath)
      .configuration(.init(renderingEngine: .coreAnimation))
      .animationDidLoad({ src in
        if firstAppear {
          doThisAfter(initialDelay) {
            playbackMode = .playing(.fromProgress(skipInitialProgress, toProgress: 1, loopMode: .playOnce))
          }
        }
      })
      .animationDidFinish({ completed in
        guard completed else { return }
        if waitingForSwitching {
          waitingForSwitching = false
          playbackMode = .paused
          withAnimation(.spring) {
            actualAnimationName = animationName
          }
          doThisAfter(0.2) { playbackMode = .playing(.toProgress(1, loopMode: .playOnce)) }
        } else if let loopDelay {
          playbackMode = .paused(at: .time(0))
          doThisAfter(loopDelay) { playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)) }
        }
      })
      .aspectRatio(contentMode: contentMode)
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
      .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
        if let loopDelay {
          playbackMode = .paused(at: .time(0))
          doThisAfter(initialDelay) { playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce)) }
        }
      }
  }
}
