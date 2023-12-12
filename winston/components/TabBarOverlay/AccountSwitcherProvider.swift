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
  private var cancellable: Timer? = nil
  @Published var positionInfo: PositionInfo? = nil { willSet { if newValue != nil && self.willEnd { cancellable?.invalidate(); withAnimation(.bouncy) { self.willEnd = false } } } }
  @Published var willEnd = false { didSet { if willEnd {
    //    if self.credentialToSet == nil { self.screenshot = nil }
    self.cancellable = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
      (self.positionInfo, self.willEnd) = (nil, false)
    }
  }}}
  @Published var screenshot: UIImage? = nil
  @Published var credentialToSet: RedditCredential? = nil
  
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
  //  @State private var credIDToSelect: UUID? = nil
  @State private var passScreen = false
  @State private var leftSlide = false
  
  var content: () -> Content
  
  func selectCredential(_ cred: RedditCredential?) {
    if let cred = cred, let nextCredIndex = RedditCredentialsManager.shared.credentials.firstIndex(of: cred) {
      let curr = RedditCredentialsManager.shared.selectedCredential
      var currCredIndex = -1
      if let curr { currCredIndex = RedditCredentialsManager.shared.credentials.firstIndex(of: curr) ?? -1 }
      leftSlide = Int(currCredIndex - nextCredIndex) <= 0
      withAnimation(.smooth) { transmitter.credentialToSet = cred }
    } else {
      doThisAfter(0) { Nav.present(.editingCredential(.init())) }
    }
  }
  
  var body: some View {
    let showScreenshot = transmitter.credentialToSet != nil
    let showOverlay = (transmitter.positionInfo != nil && !transmitter.willEnd) || showScreenshot
    let completelyFree = !showOverlay && !passScreen && !showScreenshot
    let overFramePadding: Double = !showOverlay ? 0 : showScreenshot ? 32 : 16
    ZStack {
      content()
        .environmentObject(transmitter).zIndex(1)
        .overlay {
          if showScreenshot, let screenshot = transmitter.screenshot {
            Image(uiImage: screenshot).resizable().frame(.screenSize)
              .mask(Rectangle().fill(.black).offset(x: passScreen ? (.screenW * (leftSlide ? -1 : 1)) : 0))
              .transition(.identity)
              .onAppear {
                Task(priority: .background) {
                  if let credID = transmitter.credentialToSet?.id { withAnimation { Defaults[.redditCredentialSelectedID] = credID } }
                }
                doThisAfter(0.5) {
                  withAnimation(.smooth) { passScreen = true }
                  doThisAfter(0.5) {
                    withAnimation(.smooth) { (transmitter.screenshot, transmitter.credentialToSet) = (nil, nil) }
                    doThisAfter(0.5) {
                      passScreen = false
                    }
                  }
                }
              }
          }
        }
        .blur(radius: showOverlay ? showScreenshot ? 20 : 10 : 0)
        .compositingGroup()
        .saturation(showOverlay ? showScreenshot ? 2 : 1.75 : 1)
        .opacity(showOverlay ? 0.9 : 1)
        .overlay {
          SideBySideWindow(passScreen: passScreen, leftSlide: leftSlide) {
            Rectangle().fill(EllipticalGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.2)], center: .init(x: !showOverlay ? 1 : 0.75, y: 0), startRadiusFraction: 0, endRadiusFraction: 0.85)).padding(.all, overFramePadding).opacity(!showOverlay ? 0 : 1).allowsHitTesting(false)
          }
        }
        .mask(
          SideBySideWindow(passScreen: passScreen, leftSlide: leftSlide) {
            RR(showOverlay ? showScreenshot ? 48 : 56 : 0, .black).padding(.all, overFramePadding)
          }
        )
      
      if let positionInfo = transmitter.positionInfo {
        AccountSwitcherOverlayView(fingerPosition: positionInfo, willEnd: transmitter.willEnd, selectCredential: selectCredential).equatable().zIndex(3).allowsHitTesting(false)
      }
    }
    .ignoresSafeArea(.all)
    .allowsHitTesting(completelyFree)
  }
}

struct SideBySideWindow<C: View>: View {
  var passScreen: Bool
  var leftSlide: Bool
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
    .offset(x: passScreen ? (.screenW * (leftSlide ? -1 : 1)) : 0)
    .frame(width: .screenW, alignment: leftSlide ? .leading : .trailing)
    .allowsHitTesting(false)
    .clipped()
    .drawingGroup()
  }
}
