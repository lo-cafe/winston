//
//  AccountSwitcherView.swift
//  winston
//
//  Created by Igor Marcossi on 25/11/23.
//

import SwiftUI

struct AccountSwitcherOverlayView: View, Equatable {
  static func == (lhs: AccountSwitcherOverlayView, rhs: AccountSwitcherOverlayView) -> Bool {
    lhs.fingerPosition == rhs.fingerPosition && lhs.appear == rhs.appear
  }
  
  let fingerPosition: AccountSwitcherTransmitter.PositionInfo
  let appear: Bool
  var transmitter: AccountSwitcherTransmitter
  
  @State private var showOverlay = false
  @State private var newCredentialSample = RedditCredential()
  
  
  private let targetsContainerSize: CGSize = .init(width: 250, height: 150)

  var body: some View {
    let validCredentials = RedditCredentialsManager.shared.credentials.filter { $0.validationStatus == .authorized }.reversed()
    let showAddBtn = validCredentials.count < 3
    let targetsCount = validCredentials.count + (showAddBtn ? 1 : 0)
    let lastsUntilEndOfAllTransitions = transmitter.selectedCred != nil ? (transmitter.positionInfo != nil || appear) : appear
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
      
      AccountSwitcherGradientBackground().equatable().opacity(lastsUntilEndOfAllTransitions ? 1 : 0).animation(.easeIn, value: appear)
      
      ZStack {
        if showAddBtn {
          AccountSwitcherTarget(containerSize: targetsContainerSize, index: 0, targetsCount: targetsCount, cred: newCredentialSample, transmitter: transmitter)
        }
        ForEach(Array(validCredentials.enumerated()), id: \.element) { index, cred in
          AccountSwitcherTarget(containerSize: targetsContainerSize, index: index + (showAddBtn ? 1 : 0), targetsCount: targetsCount, cred: cred, transmitter: transmitter)
        }
        
      }
      .frame(targetsContainerSize)
      .position(fingerPosition.initialLocation)
      .drawingGroup()
      
      AccountSwitcherFingerLight().equatable().position(fingerPosition.location).opacity(!appear ? 0 : 1).animation(.easeOut, value: appear).drawingGroup()
      
      AccountSwitcherParticles().equatable().opacity(lastsUntilEndOfAllTransitions ? 1 : 0).animation(.easeIn, value: appear)
      
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .multilineTextAlignment(.center)
    .ignoresSafeArea(.all)
    .allowsHitTesting(false)
  }
}
