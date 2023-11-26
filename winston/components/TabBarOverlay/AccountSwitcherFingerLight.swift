//
//  AccountSwitcherFingerLight.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI
import SpriteKit

struct AccountSwitcherFingerLightLayer: View, Equatable {
  var body: some View {
    Circle().fill(Color.hex("F1D9FF"))
      .frame(width: 50, height: 50)
      .blur(radius: 32)
  }
}

struct AccountSwitcherFingerLight: View, Equatable {
//  static func == (lhs: AccountSwitcherFingerLight, rhs: AccountSwitcherFingerLight) -> Bool {
//    true
//  }
//  @StateObject private var morph = MorphingGradientCircleScene()
  var body: some View {
//    SpriteView(scene: morph, transition: nil, isPaused: false, preferredFramesPerSecond: UIScreen.main.maximumFramesPerSecond, options: [.allowsTransparency, .ignoresSiblingOrder])
    ZStack {
      AccountSwitcherFingerLightLayer().equatable()
      AccountSwitcherFingerLightLayer().equatable()
      AccountSwitcherFingerLightLayer().equatable()
      AccountSwitcherFingerLightLayer().equatable()
    }
//    .drawingGroup()
    .offset(y: 25 - getSafeArea().bottom)
  }
}

struct AccountSwitcherParticles: View, Equatable {
  static func == (lhs: AccountSwitcherParticles, rhs: AccountSwitcherParticles) -> Bool {
    true
  }
  @StateObject private var dustScene = DustScene(size: .init(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
  var body: some View {
    SpriteView(scene: dustScene, transition: .fade(withDuration: 1000), preferredFramesPerSecond: UIScreen.main.maximumFramesPerSecond, options: [.allowsTransparency])
      .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .bottom)
      .onAppear {
        dustScene.isPaused = false
      }
      .onDisappear {
        dustScene.isPaused = true
      }
//      .offset(y: 375 - getSafeArea().bottom)
  }
}
