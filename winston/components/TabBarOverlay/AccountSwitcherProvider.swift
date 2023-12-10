//
//  AccountSwitcherProvider.swift
//  winston
//
//  Created by Igor Marcossi on 27/11/23.
//

import SwiftUI
import Combine
import Defaults

class AccountSwitcherTransmitter: ObservableObject {
  enum SwitchingState {
    case showing, hidden, selectedCred(RedditCredential)
  }
  private var cancellable: Timer? = nil
  @Published var positionInfo: PositionInfo?
  @Published var showing = false
  @Published var selectedCred: RedditCredential? = nil
  @Published var screenshot: UIImage? = nil
  @Published var credentialIDToSet: UUID? = nil
  
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
  struct AccountTransitionKit {
    var focusCloser: Bool = false
    var willLensHeadLeft: Bool = false
    var passLens: Bool = false
  }
  
  @StateObject private var transmitter = AccountSwitcherTransmitter()
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
        if #available(iOS 17.0, *) {
          withAnimation(.spring) { accTransKit.focusCloser = true } completion: {
//            withAnimation(.default.speed(20)) { transmitter.positionInfo = nil; Defaults[.redditCredentialSelectedID] = cred.id } completion: {
            transmitter.positionInfo = nil; Defaults[.redditCredentialSelectedID] = cred.id
              withAnimation(.spring) { accTransKit.passLens = true } completion: {
                withAnimation(.spring) { transmitter.screenshot = nil; accTransKit.focusCloser = false } completion: {
                  accTransKit.passLens = false
                }
              }
//            }
          }
        } else {
          // Fallback on earlier versions
        }
      } else {
        doThisAfter(0) {
          transmitter.screenshot = nil
          transmitter.positionInfo = nil
          transmitter.selectedCred = nil
          Nav.present(.editingCredential(cred))
        }
      }
    } else {
      doThisAfter(0.5) {
        transmitter.screenshot = nil
        transmitter.positionInfo = nil
      }
    }
  }
  
  var body: some View {
    let showOverlay = (transmitter.positionInfo != nil && transmitter.showing) || accTransKit.focusCloser
//        let completelyFree = !showOverlay && !accTransKit.passLens && !showScreenshot
    let completelyFree = true
    let focusFramePadding: Double = !showOverlay ? 0 : accTransKit.focusCloser ? 40 : 16
    let frameSlideOffsetX = accTransKit.passLens ? (.screenW * (accTransKit.willLensHeadLeft ? -1 : 1)) : 0
    ZStack {
      
      ZStack {
        content()
          .environmentObject(transmitter)
          .zIndex(1)
        
        if let screenshot = transmitter.screenshot {
          Image(uiImage: screenshot).resizable().frame(.screenSize)
            .blur(radius: accTransKit.focusCloser ? 20 : transmitter.showing ? 10 : 0)
            .background(.black)
//            .offset(x: frameSlideOffsetX / 5)
            .overlay {
              SideBySideWindow(passLens: accTransKit.passLens, willLensHeadLeft: accTransKit.willLensHeadLeft) {
                Rectangle().fill(EllipticalGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.2)], center: .init(x: !transmitter.showing ? 1 : 0.75, y: 0), startRadiusFraction: 0, endRadiusFraction: 0.85)).padding(.all, focusFramePadding).opacity(!transmitter.showing ? 0 : 1).allowsHitTesting(false)
              }
            }
            .mask(Rectangle().fill(.black).offset(x: frameSlideOffsetX))
            .saturation(accTransKit.focusCloser ? 2 : transmitter.showing ? 1.75 : 1)
            .transition(.identity)
            .zIndex(2)
            .drawingGroup()
        }
      }
      .mask(
        SideBySideWindow(passLens: accTransKit.passLens, willLensHeadLeft: accTransKit.willLensHeadLeft) {
          RR(showOverlay ? accTransKit.focusCloser ? 40 : 48 : .screenCornerRadius, .black).padding(.all, focusFramePadding)
        }
      )
      .frame(.screenSize)
      .background(.black)
      .animation(.spring, value: transmitter.showing)
      
      if let positionInfo = transmitter.positionInfo {
        AccountSwitcherOverlayView(fingerPosition: positionInfo, appear: transmitter.showing, transmitter: transmitter).equatable().zIndex(3).allowsHitTesting(false)
          .zIndex(3)
          .onAppear { transmitter.showing = true }
          .onChange(of: transmitter.showing) { if !$0 { selectCredential() } }
          .allowsHitTesting(false)
      }
    }
    .ignoresSafeArea(.all)
    .allowsHitTesting(completelyFree)
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