//
//  AccountSwitcherProvider.swift
//  winston
//
//  Created by Igor Marcossi on 27/11/23.
//

import SwiftUI
import Combine
import Defaults

@Observable
class AccountSwitcherTransmitter {
  enum SwitchingState {
    case showing, hidden, selectedCred(RedditCredential)
  }
  private var cancellable: Timer? = nil
  var positionInfo: PositionInfo? { willSet { self.cancellable?.invalidate() } }
  var showing = false { willSet { if newValue { self.cancellable?.invalidate() } } }
  var selectedCred: RedditCredential? = nil
  var screenshot: UIImage? = nil
  
  func scheduleReset(_ secs: Double) {
    cancellable = Timer.scheduledTimer(withTimeInterval: secs, repeats: false) { _ in
      self.reset()
    }
  }
  
  func reset() {
    self.cancellable?.invalidate()
    self.positionInfo = nil
    self.showing = false
    self.selectedCred = nil
    self.screenshot = nil
  }
  
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
  struct AccountTransitionKit: Equatable {
    var focusCloser: Bool = false
    var willLensHeadLeft: Bool = false
    var passLens: Bool = false
    var blurMain: Bool = false
  }
  
  @Environment(\.accountSwitcherTransmitter) private var transmitter
  //  @State private var credIDToSelect: UUID? = nil
  @State private var accTransKit: AccountTransitionKit = .init()
  
  var content: () -> Content
  
  func selectCredential() {
    if let cred = transmitter.selectedCred {
      if let nextCredIndex = RedditCredentialsManager.shared.credentials.firstIndex(of: cred) {
        let curr = RedditCredentialsManager.shared.selectedCredential
        var currCredIndex = -1
        if let curr { currCredIndex = RedditCredentialsManager.shared.credentials.firstIndex(of: curr) ?? -1 }
        accTransKit.willLensHeadLeft = Int(currCredIndex - nextCredIndex) <= 0
        transmitter.selectedCred = nil
        withAnimation(.snappy(extraBounce: 0.1)) { accTransKit.focusCloser = true } completion: {
          withAnimation(.linear(duration: 0.001)) { accTransKit.blurMain = true; Defaults[.GeneralDefSettings].redditCredentialSelectedID = cred.id } completion: {
            withAnimation(.spring) { accTransKit.passLens = true } completion: {
              withAnimation(.spring) { transmitter.positionInfo = nil; accTransKit.blurMain = false; transmitter.screenshot = nil; accTransKit.focusCloser = false;  } completion: {
                accTransKit.passLens = false
              }
            }
          }
        }
      } else {
        doThisAfter(0) {
          transmitter.reset()
          Nav.present(.editingCredential(cred))
        }
      }
    } else {
      transmitter.scheduleReset(0.5)
    }
  }
  
  var body: some View {
    let showOverlay = (transmitter.positionInfo != nil && transmitter.showing) || accTransKit.focusCloser
    //    let completelyFree = true
    let focusFramePadding: Double = !showOverlay ? 0 : accTransKit.focusCloser ? 40 : 16
    let frameSlideOffsetX = accTransKit.passLens ? (.screenW * (accTransKit.willLensHeadLeft ? -1 : 1)) : 0
    let somethingGoinOnYet = accTransKit.focusCloser || transmitter.showing
    //    let parallaxW = .screenW * 0.25
    ZStack {
      
      ZStack {
        content()
          .blur(radius: accTransKit.blurMain ? 10 : 0)
        //          .offset(x: accTransKit.passLens ? 0 : accTransKit.focusCloser ? (parallaxW * (accTransKit.willLensHeadLeft ? -1 : 1)) : 0)
          .zIndex(1)
        
        if let screenshot = transmitter.screenshot {
          Image(uiImage: screenshot).frame(.screenSize)
            .blur(radius: accTransKit.focusCloser ? 15 : transmitter.showing ? 10 : 0)
          //            .offset(x: accTransKit.passLens ? (parallaxW * (accTransKit.willLensHeadLeft ? -1 : 1)) : 0)
            .background(.black)
          //            .offset(x: frameSlideOffsetX / 5)
            .mask(Rectangle().fill(.black).offset(x: frameSlideOffsetX))
            .saturation(accTransKit.focusCloser ? 2 : transmitter.showing ? 1.75 : 1)
            .transition(.identity)
            .zIndex(2)
//            .drawingGroup()
            .allowsHitTesting(false)
        }
      }
      .overlay {
        SideBySideWindow(passLens: accTransKit.passLens, willLensHeadLeft: accTransKit.willLensHeadLeft) {
          Rectangle().fill(
            EllipticalGradient(
              colors: [.gray.opacity(0.5), .gray.opacity(0.2)],
              center: .init(x: !transmitter.showing ? 1 : accTransKit.focusCloser ? 0.55 : 0.75, y: 0),
              startRadiusFraction: 0,
              endRadiusFraction: 0.85)
          )
          .padding(.all, focusFramePadding)
          .opacity(!somethingGoinOnYet ? 0 : 1)
        }
        .allowsHitTesting(false)
      }
      .mask(
        SideBySideWindow(passLens: accTransKit.passLens, willLensHeadLeft: accTransKit.willLensHeadLeft) {
          RR(showOverlay ? accTransKit.focusCloser ? 40 : 48 : .screenCornerRadius, .black).padding(.all, focusFramePadding)
        }
      )
      .background(Color(.primaryInverted))
      .animation(.spring, value: transmitter.showing)
      
      if let positionInfo = transmitter.positionInfo {
        AccountSwitcherOverlayView(fingerPosition: positionInfo, appear: transmitter.showing, transmitter: transmitter).zIndex(3).allowsHitTesting(false)
          .zIndex(3)
          .onAppear { transmitter.showing = true }
          .onChange(of: transmitter.showing) { if !$0 { selectCredential() } }
          .allowsHitTesting(false)
      }
    }
    .ignoresSafeArea(.all)
    .allowsHitTesting(!(showOverlay || accTransKit.passLens))
  }
}

struct SideBySideWindow<C: View>: View {
  var passLens: Bool
  var willLensHeadLeft: Bool
  @ViewBuilder var content: () -> C
  var body: some View {
    HStack(spacing: 0) {
      Group {
        content()
        content()
      }
      .frame(.screenSize)
    }
    .frame(width: .screenW * 2, alignment: .leading)
    .scaleEffect(1)
    .offset(x: passLens ? (.screenW * (willLensHeadLeft ? -1 : 1)) : 0)
    .frame(width: .screenW, alignment: willLensHeadLeft ? .leading : .trailing)
    .allowsHitTesting(false)
    .clipped()
    .drawingGroup()
  }
}

private struct AccountSwitcherTransmitterKey: EnvironmentKey {
  static let defaultValue = AccountSwitcherTransmitter()
}

extension EnvironmentValues {
  var accountSwitcherTransmitter: AccountSwitcherTransmitter {
    get { self[AccountSwitcherTransmitterKey.self] }
    set { self[AccountSwitcherTransmitterKey.self] = newValue }
  }
}
