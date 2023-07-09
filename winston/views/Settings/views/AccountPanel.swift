//
//  AccountPanel.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct AccountPanel: View {
  @Environment(\.openURL) var openURL
  @EnvironmentObject var redditAPI: RedditAPI
  @State private var isPresentingConfirm: Bool = false
  
  var body: some View {
    List {
      Section {
        HStack {
          Image(systemName: "checkmark.circle.fill")
            .fontSize(48, .bold)
            .foregroundColor(.green)
          VStack(alignment: .leading) {
            Text("Everything amazing!")
              .fontSize(20, .bold)
            Text("Your API credentials are 👌")
          }
        }

        if let accessToken = redditAPI.loggedUser.accessToken {
          Button("Copy current access token") {
            UIPasteboard.general.string = accessToken
          }
        }
        Button("Logout") {
          isPresentingConfirm = true
        }
        .foregroundColor(.red)
        .confirmationDialog("Are you sure you wanna logoff?", isPresented: $isPresentingConfirm) {
          Button("Forget API credentials?", role: .destructive) {
            redditAPI.loggedUser.accessToken = nil
            redditAPI.loggedUser.refreshToken = nil
            redditAPI.loggedUser.expiration = nil
            redditAPI.loggedUser.lastRefresh = nil
            redditAPI.loggedUser.apiAppID = nil
            redditAPI.loggedUser.apiAppSecret = nil
          }
        }
      }
      
      
    }
    .navigationTitle("Account")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct AccountPanel_Previews: PreviewProvider {
  static var previews: some View {
    AccountPanel()
  }
}
