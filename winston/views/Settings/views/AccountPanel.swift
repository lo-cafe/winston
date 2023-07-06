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

    var body: some View {
      List {
        Section {
//          Picker("Default posts sorting", selection: $preferredSort) {
//            ForEach(SubListingSortOption.allCases, id: \.self) { val in
//              HStack(spacing: 8) {
//                Image(systemName: val.rawVal.icon)
//                Text(val.rawVal.id.capitalized)
//              }
//              .fixedSize()
//            }
//          }
        }
        if let accessToken = redditAPI.loggedUser.accessToken {
          Text(accessToken)
            .onTapGesture {
              UIPasteboard.general.string = accessToken
            }
          Button("Logout") {
            redditAPI.loggedUser.accessToken = nil
            redditAPI.loggedUser.refreshToken = nil
            redditAPI.loggedUser.expiration = nil
            redditAPI.loggedUser.lastRefresh = nil
          }
        } else {
          Button("Open auth") {
            openURL(redditAPI.getAuthorizationCodeURL())
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
