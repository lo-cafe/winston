//
//  AccountSwitcherParticles.swift
//  winston
//
//  Created by Igor Marcossi on 28/11/23.
//

import SwiftUI
import SpriteKit

//let dustScene = DustScene(size: .init(width: UIScreen.screenWidth, height: UIScreen.screenHeight))
//
//struct AccountSwitcherParticles: View, Equatable {
//  static func == (lhs: AccountSwitcherParticles, rhs: AccountSwitcherParticles) -> Bool { true }
//  @State private var showOverlay = false
//  var body: some View {
//    ZStack {
//      if showOverlay {
//        SpriteView(scene: dustScene, transition: nil, isPaused: false, preferredFramesPerSecond: UIScreen.main.maximumFramesPerSecond, options: [.allowsTransparency])
//          .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .bottom)
//      }
//    }
//    .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .bottom)
//    .onAppear {
//      withAnimation { self.showOverlay = true }
//      dustScene.isPaused = false
//      dustScene.isHidden = false
//    }
//    .onDisappear {
//      dustScene.isPaused = true
//      dustScene.isHidden = true
//    }
//  }
//}
