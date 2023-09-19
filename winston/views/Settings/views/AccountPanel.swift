//
//  AccountPanel.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import SwiftUI
import Defaults

struct AccountPanel: View {
  @Default(.redditAPIUserAgent) var redditAPIUserAgent
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
            Text("Everything Amazing!")
              .fontSize(20, .bold)
            Text("Your API credentials are 👌")
          }
        }
        
        if let accessToken = redditAPI.loggedUser.accessToken {
          Button("Copy Current Access Token") {
            UIPasteboard.general.string = accessToken
          }
          Button("Refresh Access Token") {
            Task(priority: .background) {
              await redditAPI.refreshToken(true)
            }
          }
        }
        
        Text("If Reddit ban the user-agent this app uses, you can change it to a custom one here:")
        HStack {
          Image(systemName: "person.crop.circle.fill")
          TextField("User Agent", text: $redditAPIUserAgent)
        }
      }
      
      Section {
        Button("Logout") {
          isPresentingConfirm = true
        }
        .foregroundColor(.red)
        .confirmationDialog("Are you sure you wanna logoff?", isPresented: $isPresentingConfirm, actions: {
          Button("Reset winston", role: .destructive) {
            resetApp()
            redditAPI.loggedUser.accessToken = nil
            redditAPI.loggedUser.refreshToken = nil
            redditAPI.loggedUser.expiration = nil
            redditAPI.loggedUser.lastRefresh = nil
            redditAPI.loggedUser.apiAppID = nil
            redditAPI.loggedUser.apiAppSecret = nil
          }
        }, message: { Text("This will clear everything in the app (your Reddit account is safe).") })
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
