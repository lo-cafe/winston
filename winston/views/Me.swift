//
//  Me.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI

struct Me: View {
  @Environment(\.openURL) var openURL
  @EnvironmentObject var redditAPI: RedditAPI
    var body: some View {
      VStack {
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
    }
}

struct Me_Previews: PreviewProvider {
    static var previews: some View {
        Me()
    }
}
