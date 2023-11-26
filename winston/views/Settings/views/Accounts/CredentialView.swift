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
  @State private var draftCredential = RedditCredential()
  //  @State private var draftAppID = ""
  //  @State private var draftAppSecret = ""
  //  @State private var draftAccessToken: RedditCredential.AccessToken? = nil
  //  @State private var draftRefreshToken: String? = nil
  //  @State private var draftUserName: String? = nil
  //  @State private var draftProfilePicture: String? = nil
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
              BigInput(l: "App ID", t: $draftCredential.apiAppID, placeholder: "Ex: aijsd78_UN4iuq8dm7m@mr")
              BigInput(l: "App Secret", t: $draftCredential.apiAppSecret, placeholder: "Ex: JS9amd9imaims98ajmsi-_000_md2")
            }
          }
          
          NiceCredentialSection("Tokens") {
            HStack {
              BigInfoCredential(label: "Refresh", value: draftCredential.refreshToken)
              BigInfoCredential(label: "Access", value: draftCredential.accessToken?.token, refresh: renewAccessToken)
            }.frame(height: 108)
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


struct BigInfoCredential: View {
  var label: String
  var value: String?
  var refresh: (() async -> ())? = nil
  @State private var copied = false
  @State private var refreshed = false
  @State private var bounce = 0
  @State private var spin = false
  @State private var loading = false
  var body: some View {
    let empty = value == nil || (value?.isEmpty ?? false)
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .bottom) {
        Text(label).fontSize(20, .semibold)
        
        Spacer()
        
        HStack(spacing: 12) {
          
          Button {
            UIPasteboard.general.string = value
            withAnimation(.bouncy) { copied = true; bounce += 1 }
            doThisAfter(0.3) { withAnimation { copied = false } }
          } label: {
            Image(systemName: "doc.on.clipboard")
              .symbolRenderingMode(.hierarchical)
              .brightness(copied ? 0.2 : 0)
              .ifIOS17({ img in
                if #available(iOS 17, *) {
                  img
                    .symbolEffect(.bounce, value: bounce)
                }
              })
          }
          
          if let refresh = refresh {
            Button {
              withAnimation(.bouncy) { refreshed = true; spin = true }
              doThisAfter(0.3) { refreshed = false }
              doThisAfter(0.5) { spin = false }
              withAnimation { loading = true }
              Task(priority: .background) {
                await refresh()
                await MainActor.run { withAnimation { loading = false } }
              }
            } label: {
              Image(systemName: "arrow.clockwise")
                .brightness(copied ? 0.2 : 0)
                .rotationEffect(.degrees(spin ? 360 : 0))
            }
          }
          
        }
        .fontSize(16, .semibold)
        .foregroundStyle(Color.accentColor)
        .allowsHitTesting(!empty)
        .saturation(empty ? 0 : 1)
      }
      Text(empty ? "Empty" : value).opacity(0.5)
        .fontSize(12, .medium, design: .monospaced)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .blur(radius: loading ? 24 : 0)
        .overlay {
          !loading
          ? nil
          : ProgressView()
        }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .mask(RR(16, .black))
    .background(RR(16, Color("acceptableBlack")))
    .scrollDismissesKeyboard(.interactively)
  }
}


struct BigInput: View {
  var l: String
  @Binding var t: String
  @FocusState var focused: Bool
  var placeholder: String? = nil
  @Environment(\.colorScheme) private var cs
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(l.uppercased()).fontSize(13, .semibold).padding(.horizontal, 12).opacity(0.5)
      TextField(l, text: $t, prompt: placeholder == nil ? nil : Text(placeholder!))
        .focused($focused)
        .autocorrectionDisabled(true)
        .textInputAutocapitalization(.none)
        .fontSize(16, .medium, design: .monospaced)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
          RR(16, Color("acceptableBlack"))
            .brightness(focused ? cs == .dark ? 0.1 : 0.1 : 0)
            .shadow(color: .black.opacity(focused ? cs == .dark ? 0.25 : 0.15 : 0), radius: focused ? 12 : 0, y: focused ? 6 : 0)
            .animation(.easeOut.speed(2.5), value: focused)
            .onTapGesture {
              focused = true
            }
        )
    }
  }
}

struct NiceCredentialSection<Content: View>: View {
  var label: String
  var content: () -> Content
  
  init(_ label: String, @ViewBuilder _ content: @escaping () -> Content) {
    self.label = label
    self.content = content
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(label).fontSize(20, .bold).padding(.horizontal, 4)
      content()
    }
  }
}
