//
//  EditCredWhatToDoBanner.swift
//  winston
//
//  Created by Igor Marcossi on 03/01/24.
//

import SwiftUI

struct EditCredWhatToDoBannerBody: View, Equatable {
  static func == (lhs: EditCredWhatToDoBannerBody, rhs: EditCredWhatToDoBannerBody) -> Bool {
    lhs.status == rhs.status && lhs.completionStatus == rhs.completionStatus
  }
  
  var status: RedditCredential.CredentialValidationState
  var advanced: Bool
  var openURL: () -> ()
  @Binding var completionStatus: EditCredWhatToDoBanner.BannerStatus
  @Environment(\.colorScheme) private var cs
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
        switch status {
        case .invalid:
          VStack(alignment: .leading, spacing: 4) {
            Text("Something's wrong with the credentials for this account.")
            if advanced {
              Text("We recommend you to use another key.")
            } else {
              Text("We recommend you to use another key using the \"**Guided replace**\" button below, but you can do it manually by tapping the \"**Advanced settings**\" if you want.")
            }
          }.opacity(0.8)
        case .maybeValid, .valid:
          VStack(alignment: .leading, spacing: 12) {
            Text("The credentials seem to be valid, but we need you to authorize the credentials to access your account *(yeah, it sounds redundand, sorry)*.").opacity(0.8)
            PressableButton(animation: .easeOut(duration: 0.2)) {
              switch completionStatus {
              case .fetchError, .wrongUrl, .waitingForCallback: withAnimation(.spring) { completionStatus = .onHold }
              case .success: break
              case .onHold:
                withAnimation(.spring) { completionStatus = .waitingForCallback }
                openURL()
              }
            } label: { pressed in
              HStack(spacing: 4) {
                Group {
                  switch completionStatus {
                  case .onHold:
                    Image(systemName: "arrowshape.right.fill")
                    Text("Authorize")
                  case .success:
                    BetterLottieView("party-appear", size: 19, initialDelay: 0, color: .white)
                    Text("Success!")
                  case .waitingForCallback:
                    ProgressView()
                    Text("Cancel")
                  case .wrongUrl, .fetchError:
                    BetterLottieView("error", size: 19, initialDelay: 0.2, color: .white)
                    Text("Something went wrong")
                  }
                }
                .transition(.scaleAndBlur)
              }
              .fontSize(16, .semibold)
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
              .frame(maxWidth: .infinity)
              .background(RR(12, completionStatus == .onHold ? .blue : completionStatus == .success ? .green : completionStatus == .waitingForCallback ? .gray : .pink ))
              .foregroundStyle(completionStatus == .waitingForCallback ? Color.primary : (completionStatus == .success || completionStatus == .onHold) ? Color.white : Color.pink)
              .brightness(!pressed ? 0 : cs == .dark ? 0.05 : -0.05)
            }
          }
        case .empty, .authorized: EmptyView()
        }
        
      Group {
        switch completionStatus {
        case .onHold, .success: EmptyView()
        case .waitingForCallback: Text("If it's taking too long, tap cancel and try again.")
        case .wrongUrl: Text("Something wrong with the information we received from Reddit. Please tap the error button and try again.")
        case .fetchError: Text("The authorization flow didn't work. Please tap the error button and try again or use another credential.")
        }
      }
      .opacity(0.65)
      .fontSize(14)
      .transition(.scaleAndBlur)
      .id("details-what-to-do-\(completionStatus.rawValue)")
      
    }
    .fontSize(15)
    .animation(.spring, value: completionStatus)
  }
}

struct EditCredWhatToDoBanner: View, Equatable {
  static func == (lhs: EditCredWhatToDoBanner, rhs: EditCredWhatToDoBanner) -> Bool {
    lhs.draftCredential.validationStatus != rhs.draftCredential.validationStatus
  }
  
  @Binding var draftCredential: RedditCredential
  var padding: EdgeInsets = .init(top: 12, leading: 16, bottom: 14, trailing: 16)
  var advanced = false
  
  @Environment(\.openURL) private var openURL
  @State private var completionStatus: BannerStatus = .onHold
  
  enum BannerStatus: String { case fetchError, wrongUrl, success, waitingForCallback, onHold }
  
  var body: some View {
    let status = draftCredential.validationStatus
    let statusMeta = status.getMeta()
    if status != .authorized {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "questionmark.circle.fill")
          Text("What to do now?")
        }
        .fontSize(20, .semibold)
        .padding(EdgeInsets(top: padding.top, leading: padding.leading, bottom: 0, trailing: padding.trailing))
        
        Divider()
        
        EditCredWhatToDoBannerBody(status: status, advanced: advanced, openURL: {
          openURL(RedditAPI.shared.getAuthorizationCodeURL(draftCredential.apiAppID))
        }, completionStatus: $completionStatus).equatable()
        .transition(.identity)
        .id(statusMeta.label)
        .padding(EdgeInsets(top: 0, leading: padding.leading, bottom: padding.bottom, trailing: padding.trailing))
      }
      .frame(maxWidth: .infinity)
      .themedListRowLikeBG()
      .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
//      .animation(.spring, value: statusMeta.label)
      .zIndex(completionStatus == .success ? -1 : 0)
      .multilineTextAlignment(.leading)
      .onOpenURL { url in
        if completionStatus == .waitingForCallback {
          Task(priority: .background) {
            var tempCred = draftCredential
            if let authToken = RedditAPI.shared.getAuthCodeFromURL(url) {
              let success = await RedditAPI.shared.injectFirstAccessTokenInto(&tempCred, authCode: authToken)
              await MainActor.run {
                withAnimation(.spring) {
                  completionStatus = success ? .success : .fetchError
                }
                if completionStatus == .success {
                  doThisAfter(2) {
                    withAnimation { draftCredential = tempCred }
                  }
                }
              }
            } else {
              await MainActor.run {
                withAnimation(.spring) {
                  completionStatus = .wrongUrl
                }
              }
            }
          }
        }
      }
    }
  }
}
