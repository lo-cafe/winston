//
//  CredentialsPanel.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults
import Nuke

struct CredentialsPanel: View {
  
//  @State private var selectedCredential: RedditCredential? = nil
  
  @ObservedObject private var credentialsManager = RedditCredentialsManager.shared
  @Environment(\.useTheme) private var theme
  
  var body: some View {
    List {
      Group {
        Section {
          ForEach(credentialsManager.credentials) { cred in
            CredentialPanelItem(cred: cred, deleteCred: credentialsManager.deleteCred, inUse: cred.id == credentialsManager.selectedCredential?.id)
          }
        } footer: {
          Text("To switch accounts, hold the \"me\" (or your username) tab pressed in the bottom bar.")
        }
      }
      .themedListSection()
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("Credentials")
    .toolbar {
      ToolbarItem {
        Button {
          TempGlobalState.shared.editingCredential = .init()
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .navigationBarTitleDisplayMode(.large)
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
//.themedListSection()
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
//.themedListSection()    
