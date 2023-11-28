//
//  AccountSwitcherView.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI

struct AccountSwitcherOverlayView: View, Equatable {
  static func == (lhs: AccountSwitcherOverlayView, rhs: AccountSwitcherOverlayView) -> Bool {
    lhs.fingerPosition == rhs.fingerPosition && lhs.willEnd == rhs.willEnd
  }
  
  @ObservedObject private var credentialsManager = RedditCredentialsManager.shared
  var fingerPosition: AccountSwitcherTransmitter.PositionInfo
  var willEnd: Bool
  @State private var screenshot: UIImage? = nil
  @State private var showOverlay = false
  @State private var takeScreenshot = false
  
  private let targetsContainerSize: CGSize = .init(width: 250, height: 150)
  
  
  var body: some View {
    let showOverlay = showOverlay && !willEnd
    let validCredentials = credentialsManager.credentials.filter { $0.isAuthorized }.reversed()
    ZStack(alignment: .bottom) {
      
      ZStack {
//        if let screenshot = screenshot {
//          Image(uiImage: screenshot)
//            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .bottom)
//            .opacity(showOverlay ? 0.9 : 1.0)
//            .blur(radius: showOverlay ? 2 : 0)
//            .saturation(showOverlay ? 1.5 : 1.0)
//            .onAppear { withAnimation(.smooth) { self.showOverlay = true } }
//            .background(.black)
//            .transition(.identity)
//            .allowsHitTesting(false)
//        }
        
        AccountSwitcherGradientBackground().equatable().opacity(willEnd ? 0 : 1)
        
        ZStack {
          ForEach(Array(validCredentials.enumerated()), id: \.element) { index, cred in
            AccountSwitcherTarget(containerSize: targetsContainerSize, index: index, targetsCount: validCredentials.count, fingerPos: fingerPosition.location, account: cred, willEnd: willEnd).equatable()
          }
        }
        .frame(targetsContainerSize)
        .position(fingerPosition.initialLocation)
        .drawingGroup()
        
        AccountSwitcherFingerLight().equatable().position(fingerPosition.location).opacity(willEnd ? 0 : 1)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      
      
//      AccountSwitcherParticles().equatable().opacity(willEnd ? 0 : 1)
      
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .multilineTextAlignment(.center)
    .ignoresSafeArea(.all)
    .allowsHitTesting(false)
  }
}
