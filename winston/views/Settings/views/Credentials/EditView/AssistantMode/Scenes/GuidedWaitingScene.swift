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
  @Environment(\.openURL) private var openURL
  
  var body: some View {
    VStack(spacing: 24) {
      VStack(spacing: 8) {
        BetterLottieView("owl", size: 128, loopDelay: 1, initialDelay: 0.3)
        Text("Why are you here?").fontSize(32, .bold)
        Text("The assistant should've brought you here, but you came by yourself, what happened?").opacity(0.9)
      }
      VStack(spacing: 16) {
        
        if !imLost {
          
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { imLost = true }
          } label: {
            Text("I'm lost")
          }
          
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { commonScene = nil }
          } label: {
            Text("Bring the previous screen back")
          }
          
          WinstonButton(config: .secondary) {
            nav.append(.advanced)
          } label: {
            Text("I wanna do it manually")
          }
          
        } else {
          Text("You can go back to the tutorial screen again or try the advanced mode, but if you're truly lost, I recommend you to join our Discord server.").fontSize(20, .semibold, design: .serif).opacity(0.85).padding(.bottom, 16)
            .transition(.scaleAndBlur.animation(.spring.delay(0.1)))
          
          WinstonButton(config: .secondary) {
            withAnimation(.spring) { scene = .tutorial; commonScene = nil }
          } label: {
            Label("Go back", systemImage: "arrowshape.backward.fill")
          }
          .transition(.scaleAndBlur.animation(.spring.delay(0.2)))
          
          WinstonButton(config: .secondary) {
            openURL(URL(string: "https://discord.gg/Jw3Syb3nrz")!)
          } label: {
            HStack {
              Image(.discordLogo).size(20)
              Text("Join the Discord server")
            }
          }
          .transition(.scaleAndBlur.animation(.spring.delay(0.3)))
          
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
