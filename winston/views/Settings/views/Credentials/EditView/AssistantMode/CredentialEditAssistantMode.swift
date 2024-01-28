//
//  CredentialEditAssistantMode.swift
//  winston
//
//  Created by Igor Marcossi on 01/01/24.
//

import SwiftUI

let questions: [PeakQuestion] = [
  .init(question: "Why do I need an extension?", answer: "To make the process of generating a new API credentials in your Reddit account."),
  .init(question: "What does the extension do?", answer: "It fills the form for you and clicks save basically. The problem is that Reddit's web panel is not optimized for phone devices, so it's hard to use it."),
  .init(question: "What permissions are required?", answer: "The extension have 2 jobs, to allow reddit links to open in Winston, which requires access to all sites, and to show an assistant in your API credentials settings page, which requires access to that page alone.."),
  .init(question: "Will it steal my data?", answer: "No. But the code is open source, so you can check yourself if you want, or ask about it in our Discord server. Links for both the code and the server are in **About** section in **Settings** tab.")
]

struct CredentialEditAssistantMode: View {
  weak var player: AVLooperPlayer?
  @Binding var draftCredential: RedditCredential
  @Binding var nav: [CredentialEditStack.Mode]
  enum AssistantScene { case tutorial, credsCaptured, urlError, authSuccess, authError, loadingRefreshToken }
  enum AssistantCommonScene { case waiting, empty }
  
  static let fabHeight: Double = 48
  static let fabMargin: Double = 12
  @State private var scene: AssistantScene = .tutorial
  @State private var commonScene: AssistantCommonScene? = nil
  @State private var loading = false
  @State private var timer = TimerHolder()
  
  func enableEmptyView() { withAnimation(.spring) { commonScene = .empty } }
  
  var body: some View {
    ZStack {
      Group {
        if let commonScene {
          switch commonScene {
          case .waiting:
            GuidedWaitingScene(nav: $nav, scene: $scene, commonScene: $commonScene)
          case .empty:
            EmptyView()
          }
        } else {
          switch scene {
          case .loadingRefreshToken:
            GuidedLoadingRefreshTokenScene()
          case .credsCaptured:
            GuidedCredsCapturedScene(draftCredential: draftCredential, enableEmptyView: enableEmptyView)
          case .authError:
            GuidedErrorScene(text: "It seems that your credentials aren't working!", nav: $nav, scene: $scene)
          case .authSuccess:
            GuidedAuthSuccessScene(draftCredential: draftCredential)
          case .tutorial:
            GuidedTutorialScene(player: player, enableEmptyView: enableEmptyView)
          case .urlError:
            GuidedErrorScene(text: "Something happened with your journey from Safari to the app. You have 2 choices:", nav: $nav, scene: $scene)
          }
        }
      }
      .transition(.scaleAndBlur)
    }
    .interactiveDismissDisabled()
//    .padding(.top, scene != .tutorial || commonScene != nil ? 40 : 0)
//    .navigationBarBackButtonHidden(scene != .tutorial || commonScene != nil)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .overlay(alignment: .bottom) {
      GeometryReader { _ in
        PeakQuestionsOverlay(peakQuestions: questions)
      }
      .ignoresSafeArea(.all)
    }
    .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
      if commonScene == .empty {
        timer.fireIn(0.125) { withAnimation(.spring) { commonScene = .waiting } }
      }
    }
    .onOpenURL { url in
      timer.invalidate()
      
      if let queryParams = url.queryParameters, let appID = queryParams["appID"], let appSecret = queryParams["appSecret"] {
        var newDraft = draftCredential
        newDraft.apiAppID = appID
        newDraft.apiAppSecret = appSecret
        if newDraft.validationStatus != .invalid {
          doThisAfter(0.3) {
            withAnimation(.spring) {
              draftCredential = newDraft
              scene = .credsCaptured
              commonScene = nil
            }
          }
          return
        }
      }
      
      if let authCode = RedditAPI.shared.getAuthCodeFromURL(url) {
        doThisAfter(0.3) {
          withAnimation(.spring) {
            commonScene = nil
            scene = .loadingRefreshToken
          }
          doThisAfter(0.5) {
            Task(priority: .background) {
              var tempCred = draftCredential
              let success = await RedditAPI.shared.injectFirstAccessTokenInto(&tempCred, authCode: authCode)
              await MainActor.run {
                withAnimation(.spring) {
                  draftCredential = tempCred
                  scene = success ? .authSuccess : .authError
                  commonScene = nil
                }
              }
            }
          }
        }
        return
      }
      
      withAnimation(.spring) {
        scene = .urlError
      }
      
    }
  }
}
