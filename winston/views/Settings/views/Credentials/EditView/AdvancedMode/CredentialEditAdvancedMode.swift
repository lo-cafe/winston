//
//  CredentialEditAdvancedMode.swift
//  winston
//
//  Created by Igor Marcossi on 01/01/24.
//

import SwiftUI

struct CredentialEditAdvancedMode: View {
  var credential: RedditCredential
  @Binding var draftCredential: RedditCredential
  @State private var waitingForCallback: Bool? = nil
  
  @Environment(\.useTheme) private var theme
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  
  func renewAccessToken() async {
    let newToken = await draftCredential.getUpToDateToken(forceRenew: true)
    draftCredential.accessToken = newToken
  }
  
  var isDraftValid: Bool { draftCredential.validationStatus != .invalid }
  
  var body: some View {
    let credMeta = draftCredential.validationStatus.getMeta()
    let anyChanges = credential != draftCredential
    
    ScrollView {
      VStack(spacing: 24) {
        
        AdvancedInstructions()
        
          NiceCredentialSectionExtra("Credentials", footer: "The Safari extension also works in this screen. It'll just fill it up for you.") {
            VStack(alignment: .leading, spacing: 16) {
              VStack(alignment: .leading, spacing: 16) {
                BigInput(l: "App ID", bg: .acceptablePrimary, t: Binding(get: {
                  draftCredential.apiAppID
                }, set: { draftCredential.apiAppID = $0.replacingOccurrences(of: " ", with: "")
                }), placeholder: "Ex: aijsd78_UN4iuq8dm7m@mr")
                
                BigInput(l: "App Secret", bg: .acceptablePrimary, t: Binding(get: {
                  draftCredential.apiAppSecret
                }, set: { draftCredential.apiAppSecret = $0.replacingOccurrences(of: " ", with: "")
                }), placeholder: "Ex: JS9amd9imaims98ajmsi-_000_md2")
              }
              .padding(.horizontal, 12)
              
              if draftCredential.validationStatus != .empty {
                EditCredWhatToDoBanner(draftCredential: $draftCredential, padding: EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16), advanced: true)
              }
            }
            .padding(.vertical, 10)
            .themedListRowLikeBG()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          } trailing: {
            VStack {
              CredentialStatusMetaView(credMeta)
            }.animation(.spring, value: credMeta)
          }
//
        NiceCredentialSection("Tokens") {
          HStack {
            BigInfoCredential(label: "Refresh", value: draftCredential.refreshToken)
            BigInfoCredential(label: "Access", value: draftCredential.accessToken?.token, refresh: renewAccessToken)
          }.frame(height: 108)
        }
//        
        Button {
          openURL(redditApiSettingsUrl)
        } label: {
          HStack(spacing: 0) {
            Image(.redditLogo)
              .resizable()
              .scaledToFit()
              .frame(height: 24)
            Text("Open Reddit API page")
          }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .trailing)
        
      }
      .padding(.top, 16)
      .padding(.horizontal, 16)
    }
    .animation(.spring, value: draftCredential.validationStatus)
    .themedListBG(theme.lists.bg)
    .navigationTitle("Advanced")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Save") {
          draftCredential.save()
          dismiss()
        }
        .disabled(!anyChanges)
      }
    }
    .onOpenURL { url in
      if let queryParams = url.queryParameters, let appID = queryParams["appID"], let appSecret = queryParams["appSecret"] {
        draftCredential.apiAppID = appID
        draftCredential.apiAppSecret = appSecret
        if draftCredential.validationStatus != .invalid {
          openURL(RedditAPI.shared.getAuthorizationCodeURL(draftCredential.apiAppID))
        }
      } else if waitingForCallback == true {
        Task(priority: .background) {
          var tempCred = draftCredential
          //          if let authCode = await RedditAPI.shared.monitorAuthCallback( url)
          await MainActor.run {
            //            if success {
            //              withAnimation { draftCredential = tempCred }
            //            }
            //            withAnimation {
            //              waitingForCallback = success ? nil : false
            //            }
          }
        }
      }
    }
  }
}
