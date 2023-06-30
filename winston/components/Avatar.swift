//
//  Avatar.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import SwiftUI
import CachedAsyncImage

struct Avatar: View {
  var userID: String
  @State var userData: UserData?
  @EnvironmentObject var redditAPI: RedditAPI
  var body: some View {
    Group {
      if let iconImg = userData?.iconImg {
        CachedAsyncImage(url: URL(string: iconImg)) { image in
          image
            .resizable()
            .scaledToFill()
        } placeholder: {
          Text(userID.prefix(1))
            .background(
              Circle()
                .fill(.gray.opacity(0.5))
            )
        }
      } else {
        Text(userID.prefix(1).uppercased())
          .background(
            Circle()
              .fill(.gray.opacity(0.5))
              .frame(width: 30, height: 30)
          )
          .onAppear {
            Task {
              if let data = await redditAPI.fetchUser(userID: userID) {
                userData = data
              }
            }
          }
      }
    }
    .frame(width: 30, height: 30)
    .mask(Circle())
  }
}
//
//struct Avatar_Previews: PreviewProvider {
//    static var previews: some View {
//        Avatar()
//    }
//}
