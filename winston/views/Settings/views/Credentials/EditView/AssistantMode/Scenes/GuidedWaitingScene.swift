//
//  GuidedWaitingScene.swift
//  winston
//
//  Created by Igor Marcossi on 06/01/24.
//

import SwiftUI

struct GuidedWaitingScene: View {
  @Binding var nav: [CredentialEditStack.Mode]
  @Binding var scene: CredentialEditAssistantMode.AssistantScene
  @Binding var commonScene: CredentialEditAssistantMode.AssistantCommonScene?
  @State private var imLost = false
  @State private var state: WaitingState = .start
  @Environment(\.openURL) private var openURL
  
  enum WaitingState { case oauth, lost, start }
  
  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 8) {
        BetterLottieView("owl", size: 128, loopDelay: 1, initialDelay: 0.3)
        Text("Why are you here?").fontSize(32, .bold)
        Text("The assistant should've brought you here, but you came by yourself, what happened?").opacity(0.9)
      }
      VStack(spacing: 16) {
        
        switch state {
        case .start:
          if scene == .credsCaptured {
            WinstonButton(config: .secondary) {
              withAnimation(.spring) { state = .oauth }
            } label: {
              Label("I got an OAuth error", systemImage: "xmark.circle.fill")
            }
          }
          
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { state = .lost }
          } label: {
            Label("I'm lost!", systemImage: "location.slash.fill")
          }
          
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { commonScene = nil }
          } label: {
            Label("Go to previous screen", systemImage: "arrowshape.left.fill")
          }
          
          WinstonButton(config: .secondary) {
            nav.append(.advanced)
          } label: {
            Label("I wanna do it manually", systemImage: "hand.raised.fingers.spread.fill")
          }
          
        case .oauth:
          Text("That error seems happen randomly. It usually helps if you create another credential in Reddit site and try again.").fontSize(19, .semibold, design: .serif).opacity(0.85).padding(.bottom, 16)
            .transition(.scaleAndBlur.animation(.spring.delay(0.1)))
          
        case .lost:
          Text("You can go back to the tutorial screen again or try the advanced mode, but if you're truly lost, I recommend you to join our Discord server.").fontSize(19, .semibold, design: .serif).opacity(0.85).padding(.bottom, 16)
            .transition(.scaleAndBlur.animation(.spring.delay(0.1)))
        }
        
        if state != .start {
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { commonScene = nil }
          } label: {
            Label("Go to previous screen", systemImage: "arrowshape.left.fill")
          }
          .transition(.scaleAndBlur.animation(.spring.delay(0.2)))
          
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { scene = .tutorial; commonScene = nil }
          } label: {
            Label("Restart tutorial", systemImage: "arrow.clockwise")
          }
          .transition(.scaleAndBlur.animation(.spring.delay(0.3)))
          
          WinstonButton(config: .secondary) {
            openURL(URL(string: "https://discord.gg/Jw3Syb3nrz")!)
          } label: {
            HStack {
              Image(.discordLogo).size(20)
              Text("Join the Discord server")
            }
          }
          .transition(.scaleAndBlur.animation(.spring.delay(0.4)))
        }
        
      }
    }
    .multilineTextAlignment(.center)
    .padding(EdgeInsets(top: 48, leading: 32, bottom: 0, trailing: 32))
    .frame(maxHeight: .infinity, alignment: .top)
    //      .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
    //        print("foreground")
    //      }
  }
}
