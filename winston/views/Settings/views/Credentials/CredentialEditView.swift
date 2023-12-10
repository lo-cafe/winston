//
//  CredentialEditView.swift
//  winston
//
//  Created by Igor Marcossi on 22/11/23.
//

import SwiftUI
import NukeUI

struct CredentialEditView: View {
  var credential: RedditCredential
  @State private var draftCredential = RedditCredential()
  @State private var waitingForCallback: Bool? = nil
  
  @Environment(\.useTheme) private var theme
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  
  func renewAccessToken() async {
    let newToken = await draftCredential.getUpToDateToken(forceRenew: true)
    draftCredential.accessToken = newToken
  }
  
  var body: some View {
    let verified = draftCredential.refreshToken != nil
    //    let anyChanges = credential.apiAppID != draftAppID || credential.apiAppSecret != draftAppSecret || credential.refreshToken != draftRefreshToken || credential.accessToken != draftAccessToken
    let anyChanges = credential != draftCredential
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          VStack {
            if let profilePicture = draftCredential.profilePicture, let url = URL(string: profilePicture) {
              URLImage(url: url)
                .scaledToFill()
                .frame(72)
                .mask(Circle().fill(.black))
            } else {
              Image(systemName: "person.text.rectangle.fill")
                .fontSize(28)
                .frame(72)
                .background(Circle().fill(Color.accentColor.opacity(0.25)))
            }
            Text(credential.userName ?? "New credential").fontSize(24, .semibold)
          }
          .listRowInsets(.none)
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
          
          HStack {
            HStack(spacing: 4) {
              Image(systemName: verified ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .fontSize(38)
                .foregroundStyle(verified ? .green : .orange)
                .transition(.scaleAndBlur)
                .id("verified-icon-\(verified ? "1" : "0")")
              VStack(alignment: .leading, spacing: -1) {
                Text("Status").fontSize(13, .medium).opacity(0.75)
                Text(verified ? "Authorized" : "Unauthorized")
                  .fontSize(17, .semibold)
                  .foregroundStyle(verified ? .green : .orange)
                  .transition(.scaleAndBlur)
                  .id("verified-icon-\(verified ? "1" : "0")")
              }
            }
            
            Spacer()
            
            Button {
              if !draftCredential.apiAppID.isEmpty {
                if waitingForCallback == true { return withAnimation(.spring) { waitingForCallback = false } }
                if waitingForCallback == false { return withAnimation(.spring) { waitingForCallback = nil } }
                withAnimation(.spring) { waitingForCallback = true }
                openURL(RedditAPI.shared.getAuthorizationCodeURL(draftCredential.apiAppID))
              }
            } label: {
              HStack(spacing: 4) {
                if waitingForCallback == true {
                  ProgressView()
                    .transition(.scaleAndBlur)
                } else {
                  Image(systemName: waitingForCallback == false ? "xmark.circle.fill" : verified ? "checkmark.gobackward" : "arrowshape.right.fill")
                    .transition(.scaleAndBlur)
                }
                let label = waitingForCallback == true ? "Waiting..." : waitingForCallback == false ? "Try again" : verified ? "Reauthorize" : "Authorize"
                Text(label)
                  .transition(.scaleAndBlur)
                  .id(label)
              }
              .fontSize(16, .semibold)
              .padding(.horizontal, 14)
              .padding(.vertical, 10)
              .background(RR(12, waitingForCallback == true ? .gray : waitingForCallback == false ? .red : verified ? Color("acceptablePrimary") : .green))
              .foregroundStyle(waitingForCallback == true ? Color.primary : Color.white)
            }
            .buttonStyle(.plain)
            .fixedSize(horizontal: true, vertical: false)
            .disabled(draftCredential.apiAppID.isEmpty || draftCredential.apiAppSecret.isEmpty)
          }
          
          NiceCredentialSection("Credentials") {
            VStack(alignment: .leading, spacing: 16) {
              
              BigInput(l: "App ID", t: Binding(get: {
                draftCredential.apiAppID
              }, set: { draftCredential.apiAppID = $0.replacingOccurrences(of: " ", with: "")
              }), placeholder: "Ex: aijsd78_UN4iuq8dm7m@mr")
              
              BigInput(l: "App Secret", t: Binding(get: {
                draftCredential.apiAppSecret
              }, set: { draftCredential.apiAppSecret = $0.replacingOccurrences(of: " ", with: "")
              }), placeholder: "Ex: JS9amd9imaims98ajmsi-_000_md2")
            }
          }
          
          NiceCredentialSection("Tokens") {
            HStack {
              BigInfoCredential(label: "Refresh", value: draftCredential.refreshToken)
              BigInfoCredential(label: "Access", value: draftCredential.accessToken?.token, refresh: renewAccessToken)
            }.frame(height: 108)
          }
          
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
      .themedListBG(theme.lists.bg)
      .navigationTitle("Edit credential")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel", role: .destructive) {
            dismiss()
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            draftCredential.save()
            dismiss()
          }
          .disabled(!anyChanges)
        }
      }
      .onAppear {
        draftCredential = credential
      }
      .onOpenURL { url in
        
        if let queryParams = url.queryParameters, let appID = queryParams["appID"], let appSecret = queryParams["appSecret"] {
          draftCredential.apiAppID = appID
          draftCredential.apiAppSecret = appSecret
        }
        
        
        if waitingForCallback == true {
          Task(priority: .background) {
            var tempCred = draftCredential
            let success = await RedditAPI.shared.monitorAuthCallback(credential: &tempCred, url)
            await MainActor.run {
              if success {
                withAnimation { draftCredential = tempCred }
              }
              withAnimation {
                waitingForCallback = success ? nil : false
              }
            }
          }
        }
      }
      .interactiveDismissDisabled(anyChanges)
    }
  }
}
