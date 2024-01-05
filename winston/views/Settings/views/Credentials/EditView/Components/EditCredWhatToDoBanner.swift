//
//  EditCredWhatToDoBanner.swift
//  winston
//
//  Created by Igor Marcossi on 03/01/24.
//

import SwiftUI

struct EditCredWhatToDoBanner: View {
  @Binding var draftCredential: RedditCredential
  
  @State private var completionStatus: BannerStatus = .onHold
  @Environment(\.openURL) private var openURL
  @Environment(\.colorScheme) private var cs
  
  enum BannerStatus { case fetchError, wrongUrl, success, waitingForCallback, onHold }
  
  var body: some View {
    let status = draftCredential.validationStatus
    if status != .authorized {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Image(systemName: "questionmark.circle.fill")
          Text("What to do now?")
        }
        .fontSize(20, .semibold)
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 16))
        
        Divider()
        
        VStack(alignment: .leading, spacing: 12) {
          switch status {
          case .invalid:
            VStack(alignment: .leading, spacing: 4) {
              Text("Something's wrong with the credentials we have for this account.")
              Text("We recommend you to use another key using the \"**Guided replace**\" button below, but you can do it manually by tapping the \"**Advanced settings**\" if you want.")
            }.opacity(0.8)
          case .maybeValid, .valid:
            Text("The credentials we have seem to be valid, but we need you to authorize the credentials to access your account (yeah, it sounds redundand, sorry).").opacity(0.85)
            PressableButton(animation: .easeOut(duration: 0.2)) {
              switch completionStatus {
              case .fetchError, .wrongUrl, .waitingForCallback: withAnimation(.spring) { completionStatus = .onHold }
              case .success: break
              case .onHold:
                withAnimation(.spring) { completionStatus = .waitingForCallback }
                openURL(RedditAPI.shared.getAuthorizationCodeURL(draftCredential.apiAppID))
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
          case .authorized: EmptyView()
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
        }
        .fontSize(15)
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
      }
      .frame(maxWidth: .infinity)
      .themedListRowLikeBG()
      .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
      .zIndex(completionStatus == .success ? -1 : 0)
      .multilineTextAlignment(.leading)
      .onOpenURL { url in
        if completionStatus == .waitingForCallback {
          Task(priority: .background) {
            var tempCred = draftCredential
            let success = await RedditAPI.shared.monitorAuthCallback(credential: &tempCred, url)
            await MainActor.run {
              withAnimation(.spring) {
                completionStatus = switch success {
                case true: .success
                case false: .fetchError
                case nil: .wrongUrl
                default: .onHold
                }
              }
              if completionStatus == .success {
                doThisAfter(2) {
                  withAnimation { draftCredential = tempCred }
                }
              }
            }
          }
        }
        
      }
    }
  }
}
