//
//  CredentialView.swift
//  winston
//
//  Created by Igor Marcossi on 22/11/23.
//

import SwiftUI
import NukeUI

struct CredentialView: View {
  var credential: RedditCredential
  @State private var modifiableCredential: RedditCredential? = nil
  @State private var draftAppID = ""
  @State private var draftAppSecret = ""
  @State private var draftAccessToken: RedditCredential.AccessToken? = nil
  @State private var draftRefreshToken: String? = nil
  @State private var draftUserName: String? = nil
  @State private var draftProfilePicture: String? = nil
  @State private var waitingForCallback: Bool? = nil
  
  @Environment(\.useTheme) private var theme
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) var openURL
  var body: some View {
    let verified = draftRefreshToken != nil && draftAccessToken != nil
    let anyChanges = credential.apiAppID != draftAppID || credential.apiAppSecret != draftAppSecret || credential.refreshToken != draftRefreshToken || credential.accessToken != draftAccessToken
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          VStack {
            if let profilePicture = credential.profilePicture, let url = URL(string: profilePicture) {
              LazyImage(url: url) { result in
                if case .success(let imgResponse) = result.result {
                  Image(uiImage: imgResponse.image).resizable()
                }
              }
              .scaledToFill()
              .padding(12)
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
            HStack(spacing: 8) {
              Image(systemName: verified ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .fontSize(38)
                .foregroundStyle(verified ? .green : .yellow)
                .transition(.scaleAndBlur)
                .id("verified-icon-\(verified ? "1" : "0")")
              VStack(alignment: .leading, spacing: 0) {
                Text("Status").fontSize(13, .medium).opacity(0.75)
                Text(verified ? "Authorized" : "Unauthorized")
                  .fontSize(17, .semibold)
                  .foregroundStyle(verified ? .green : .yellow)
                  .transition(.scaleAndBlur)
                  .id("verified-icon-\(verified ? "1" : "0")")
              }
            }
            
            Spacer()
            
            Button {
              if waitingForCallback == true { return withAnimation(.spring) { waitingForCallback = false } }
              if waitingForCallback == false { return withAnimation(.spring) { waitingForCallback = nil } }
              withAnimation(.spring) { waitingForCallback = true }
              openURL(RedditAPI.shared.getAuthorizationCodeURL(draftAppID))
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
              .background(RR(12, waitingForCallback == true ? .gray : waitingForCallback == false ? .red : verified ? .blue : .green))
              .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .fixedSize(horizontal: true, vertical: false)
            .disabled(draftAppID.isEmpty || draftAppSecret.isEmpty)
          }
          
          VStack(alignment: .leading, spacing: 6) {
            Text("App ID").fontSize(16, .medium).padding(.horizontal, 12)
            BigInput(t: $draftAppID, placeholder: "Ex: aijsd78_UN4iuq8dm7m@mr")
          }
          
          VStack(alignment: .leading, spacing: 6) {
            Text("App Secret").fontSize(16, .medium).padding(.horizontal, 12)
            BigInput(t: $draftAppSecret, placeholder: "Ex: JS9amd9imaims98ajmsi-_000_md2")
          }
          
          Button {
            openURL(URL(string: "https://www.reddit.com/prefs/apps")!)
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
      .themedListBG(.color(theme.lists.foreground.color))
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
            modifiableCredential?.apiAppID = draftAppID
            modifiableCredential?.apiAppSecret = draftAppSecret
            modifiableCredential?.refreshToken = draftRefreshToken
            modifiableCredential?.accessToken = draftAccessToken
            modifiableCredential?.userName = draftUserName
            modifiableCredential?.profilePicture = draftProfilePicture
            modifiableCredential?.save()
            dismiss()
          }
          .disabled(!anyChanges)
        }
      }
      .onAppear {
        modifiableCredential = credential
        draftRefreshToken = credential.refreshToken
        draftAppID = credential.apiAppID ?? ""
        draftAppSecret = credential.apiAppSecret ?? ""
        draftUserName = credential.userName
        draftProfilePicture = credential.profilePicture
      }
      .onOpenURL { url in
        if waitingForCallback == true {
          Task(priority: .background) {
            if let (accessData, meData) = await RedditAPI.shared.monitorAuthCallback(draftAppID, draftAppSecret, url) {
              DispatchQueue.main.async {
                waitingForCallback = nil
                draftAccessToken = .init(token: accessData.access_token, expiration: accessData.expires_in, lastRefresh: Date())
                draftRefreshToken = accessData.refresh_token
                draftUserName = meData.name
                draftProfilePicture = meData.icon_img
              }
            } else {
              waitingForCallback = false
            }
          }
        }
      }
      .interactiveDismissDisabled(anyChanges)
    }
  }
}


struct BigInput: View {
  @Binding var t: String
  var placeholder: String? = nil
  var body: some View {
    TextField("", text: $t, prompt: placeholder == nil ? nil : Text(placeholder!))
      .autocorrectionDisabled(true)
      .textInputAutocapitalization(.none)
      .fontSize(16, .medium)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .padding(.horizontal, 12)
      .background(RR(16, Color.gray.opacity(0.25)))
  }
}
