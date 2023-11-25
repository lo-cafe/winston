//
//  AccountsPanel.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults
import Nuke

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
                  URLImage(url: url, processors: [.resize(size: .init(width: 32, height: 32))])
                  .scaledToFill()
                  .frame(32)
                  .mask(Circle().fill(.black))
                } else {
                  Image(systemName: "person.text.rectangle.fill")
                    .foregroundStyle(Color.accentColor)
                    .fontSize(20)
                }

              Text(cred.userName ?? (cred.apiAppID.isEmpty ? "Empty credential" : cred.apiAppID))
              
              Spacer()
              
              if cred.refreshToken == nil {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
              }
            }
          }
          .contextMenu(ContextMenu(menuItems: {
            if let accessToken = cred.accessToken?.token {
              Button("Copy access token", systemImage: "doc.on.clipboard") {
                UIPasteboard.general.string = accessToken
              }
            }
            if cred.refreshToken != nil {
              Button("Refresh access token", systemImage: "arrow.clockwise") {
                Task(priority: .background) { _ = await cred.getUpToDateToken(forceRenew: true) }
              }
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
              credentialsManager.deleteCred(cred)
            }
          }))
        }
      } footer: {
        Text("To switch accounts, hold the \"me\" (or your username) tab pressed in the bottom bar.")
      }
    }
    .themedListBG(theme.lists.bg)
    .navigationTitle("Accounts")
    .toolbar {
      ToolbarItem {
        Button {
          selectedCredential = .init()
        } label: {
          Image(systemName: "plus")
        }
      }
    }
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
