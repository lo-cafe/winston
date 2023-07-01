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
  @State var user: User?
  @State var loading = true
  var body: some View {
    GoodNavigator {
      Group {
        if let user = user {
          UserView(user: user)
        } else {
          ProgressView()
            .progressViewStyle(.circular)
            .frame(maxWidth: .infinity, minHeight: 300 )
        }
        
//        if let refreshToken = redditAPI.loggedUser.refreshToken {
//          Text(refreshToken)
//          Button("Logout") {
//            redditAPI.loggedUser.accessToken = nil
//            redditAPI.loggedUser.refreshToken = nil
//            redditAPI.loggedUser.expiration = nil
//            redditAPI.loggedUser.lastRefresh = nil
//          }
//        } else {
//          Button("Open auth") {
//            openURL(redditAPI.getAuthorizationCodeURL())
//          }
//        }
      }
    }
    .onAppear {
      Task {
        if let newUser = await redditAPI.fetchMe() {
          user = newUser
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
