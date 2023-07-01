//
//  Settings.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults

struct Settings: View {
  @Environment(\.openURL) var openURL
  @Default(.preferredSort) var preferredSort
  @EnvironmentObject var redditAPI: RedditAPI
  var body: some View {
    GoodNavigator {
      VStack {
        List {
          Section {
            Picker("Default posts sorting", selection: $preferredSort) {
              ForEach(SubListingSortOption.allCases, id: \.self) { val in
                HStack(spacing: 8) {
                  Image(systemName: val.rawVal.icon)
                  Text(val.rawVal.id.capitalized)
                }
                .fixedSize()
              }
            }
          }
        }
                if let refreshToken = redditAPI.loggedUser.refreshToken {
                  Text(refreshToken)
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
      .navigationTitle("Settings")
    }
  }
}

//struct Settings_Previews: PreviewProvider {
//  static var previews: some View {
//    Settings()
//  }
//}
