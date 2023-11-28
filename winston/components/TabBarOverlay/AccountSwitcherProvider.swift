//
//  AccountSwitcherProvider.swift
//  winston
//
//  Created by Igor Marcossi on 27/11/23.
//

import SwiftUI
import Combine

class AccountSwitcherTransmitter: ObservableObject {
  private var cancellable: Timer? = nil
  @Published var positionInfo: PositionInfo? = nil { willSet { if self.willEnd { cancellable?.invalidate(); withAnimation(.bouncy) { self.willEnd = false } } } }
  @Published var willEnd = false { didSet { if willEnd {
    self.cancellable = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
      self.positionInfo = nil; self.willEnd = false
    }
  }}}
  
  struct PositionInfo: Equatable, Hashable {
    static let zero = PositionInfo(.zero)
    private var _location: CGPoint? = nil
    var location: CGPoint {
      get { _location ?? initialLocation }
      set { _location = newValue }
    }
    var initialMovement: Bool { _location == nil }
    let initialLocation: CGPoint
    
    init(_ loc: CGPoint) {
      self.initialLocation = loc
    }
  }
}

struct AccountSwitcherProvider<Content: View>: View {
  @StateObject private var transmitter = AccountSwitcherTransmitter()
  var content: () -> Content
    var body: some View {
      let showOverlay = transmitter.positionInfo != nil && !transmitter.willEnd
      ZStack {
        content()
          .environmentObject(transmitter).zIndex(1)
          .blur(radius: showOverlay ? 2.5 : 0)
          .compositingGroup()
          .saturation(showOverlay ? 1.5 : 1)
          .opacity(showOverlay ? 0.9 : 1)
        if let positionInfo = transmitter.positionInfo {
          AccountSwitcherOverlayView(fingerPosition: positionInfo, willEnd: transmitter.willEnd).equatable().zIndex(2).allowsHitTesting(false)
        }
      }
      .ignoresSafeArea()
    }
}
