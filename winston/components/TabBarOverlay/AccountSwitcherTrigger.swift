//
//  AccountSwitcherTrigger.swift
//  winston
//
//  Created by Igor Marcossi on 27/11/23.
//

import SwiftUI

struct AccountSwitcherTrigger<Content: View>: View {
  @EnvironmentObject private var transmitter: AccountSwitcherTransmitter
  @ObservedObject private var credentialsManager = RedditCredentialsManager.shared
  @State private var medium = UIImpactFeedbackGenerator(style: .soft)
  @State private var dragging = false
  @State private var triggerLocation: CGPoint? = nil
  @State private var takeScreenshot = false

  
  var onTap: (()->())? = nil
  var content: () -> Content
  
  var body: some View {
    content()
      .background( GeometryReader { geo in
        Color.clear
          .allowsHitTesting(false)
          .onChange(of: dragging) { if $0 {
            medium.impactOccurred()
            withAnimation(.spring) {
              takeScreenshot = false
              transmitter.positionInfo = .init(geo.frame(in: .global).point(at: .center))
            }
          }}
      })
      .background(TakeSnapshotView(screenshot: $transmitter.screenshot, takeScreenshot: takeScreenshot))
      .simultaneousGesture(onTap == nil || dragging ? nil : TapGesture().onEnded { _ in if !dragging { onTap?() } })
      .simultaneousGesture(
        LongPressGesture(minimumDuration: 0.1)
          .onEnded({ _ in
            takeScreenshot = true
            dragging = true
            medium.prepare()
          })
          .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
          .onChanged { sequence in
            if case .second(_, let dragVal) = sequence, let dragVal = dragVal {
              withAnimation((transmitter.positionInfo?.initialMovement ?? false) ? .interactiveSpring : nil) {
                transmitter.positionInfo?.location = dragVal.location
              }
            }
          }
          .onEnded({ sequence in
            if case .second(_, _) = sequence {
              withAnimation(.spring) {
                transmitter.willEnd = true
                dragging = false
              }
            }
          })
      )
  }
}
