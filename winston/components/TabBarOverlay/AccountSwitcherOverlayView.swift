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
  
  var fingerPosition: AccountSwitcherTransmitter.PositionInfo
  var willEnd: Bool
  var selectCredential: (RedditCredential?) -> ()
  
  @ObservedObject private var credentialsManager = RedditCredentialsManager.shared
  @State private var showOverlay = false
  
  private let targetsContainerSize: CGSize = .init(width: 250, height: 150)

  var body: some View {
    //    let showOverlay = showOverlay && !willEnd
    let validCredentials = credentialsManager.credentials.filter { $0.isAuthorized }.reversed()
    let showAddBtn = validCredentials.count < 3
    let targetsCount = validCredentials.count + (showAddBtn ? 1 : 0)
    ZStack(alignment: .bottom) {
      //        if let screenshot = screenshot {
      //          Image(uiImage: screenshot)
      //            .frame(.screenSize,  .bottom)
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
        if showAddBtn {
          AccountSwitcherTarget(containerSize: targetsContainerSize, index: 0, targetsCount: targetsCount, fingerPos: fingerPosition.location, cred: nil, willEnd: willEnd, selectCredential: selectCredential)
        }
        ForEach(Array(validCredentials.enumerated()), id: \.element) { index, cred in
          AccountSwitcherTarget(containerSize: targetsContainerSize, index: index + (showAddBtn ? 1 : 0), targetsCount: targetsCount, fingerPos: fingerPosition.location, cred: cred, willEnd: willEnd, selectCredential: selectCredential)
        }
        
      }
      .frame(targetsContainerSize)
      .position(fingerPosition.initialLocation)
      .drawingGroup()
      
      AccountSwitcherFingerLight().equatable().position(fingerPosition.location).opacity(willEnd ? 0 : 1)
        .drawingGroup()
      
      AccountSwitcherParticles().equatable().opacity(willEnd ? 0 : 1)
      
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .multilineTextAlignment(.center)
    .ignoresSafeArea(.all)
    .allowsHitTesting(false)
  }
}
