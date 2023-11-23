//
//  AccountsPanel.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults
import NukeUI

struct AccountsPanel: View {
  
  @State private var selectedCredential: RedditCredential? = nil
  
  @ObservedObject private var credentialsManager = RedditCredentialsManager.shared
  @Environment(\.useTheme) private var theme
  
  var body: some View {
    List {
      Section {
        ForEach(credentialsManager.credentials) { cred in
          WListButton(showArrow: true) {
            selectedCredential = cred
          } label: {
            HStack {
                if let profilePicture = cred.profilePicture, let url = URL(string: profilePicture) {
                  LazyImage(url: url) { result in
                    if case .success(let imgResponse) = result.result {
                      Image(uiImage: imgResponse.image).resizable()
                    }
                  }
                  .scaledToFill()
                  .padding(6)
                  .frame(32)
                  .mask(Circle().fill(.black))
                } else {
                  Image(systemName: "person.text.rectangle.fill")
                    .frame(32)
                    .background(Circle().fill(Color.accentColor.opacity(0.25)))
                }

              Text(cred.userName ?? cred.apiAppID ?? "Empty credential")
            }
          }
        }
      } footer: {
        Text("To switch accounts, hold the \"me\" (or your username) tab pressed in the bottom bar.")
      }
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("Accounts")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $selectedCredential) { cred in
      CredentialView(credential: cred)
    }
  }
}


//Section {
//  HStack {
//    Image(systemName: "checkmark.circle.fill")
//      .fontSize(48, .bold)
//      .foregroundColor(.green)
//    VStack(alignment: .leading) {
//      Text("Everything Amazing!")
//        .fontSize(20, .bold)
//      Text("Your API credentials are 👌")
//    }
//  }
//  .themedListRowBG(enablePadding: true)
//  
//  if let accessToken = RedditCredentialsManager.shared.selectedCredential?.accessToken?.token {
//    WSListButton("Copy Current Access Token", icon: "clipboard") {
//      UIPasteboard.general.string = accessToken
//    }
//    
//    WSListButton("Refresh Access Token", icon: "arrow.clockwise") {
//      Task(priority: .background) {
//        _ = await RedditCredentialsManager.shared.selectedCredential?.getUpToDateToken(forceRenew: true)
//      }
//    }
//  }
//  
//  Text("If Reddit ban the user-agent this app uses, you can change it to a custom one here:")
//    .themedListRowBG(enablePadding: true)
//  
//  HStack {
//    Image(systemName: "person.crop.circle.fill")
//    TextField("User Agent", text: $redditAPIUserAgent)
//  }
//  .themedListRowBG(enablePadding: true)
//}
//.themedListDividers()
//
//Section {
//  WSListButton("Logout", icon: "door.right.hand.open") {
//    isPresentingConfirm = true
//  }
//  .foregroundColor(.red)
//  .confirmationDialog("Are you sure you wanna logoff?", isPresented: $isPresentingConfirm, actions: {
//    Button("Reset winston", role: .destructive) {
//      resetApp()
//      RedditCredentialsManager.shared.reset()
//    }
//  }, message: { Text("This will clear everything in the app (your Reddit account is safe).") })
//}
//.themedListDividers()    
