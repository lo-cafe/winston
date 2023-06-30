//
//  fetchUser.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchUser(userID: String) async -> UserData? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
    let response = await AF.request("\(RedditAPI.redditWWWApiURLBase)/user/\(userID)/about.json",
                                      method: .get,
                                      headers: headers
      )
        .serializingDecodable(ListingChild<UserData>.self).response
      switch response.result {
      case .success(let data):
        return data.data
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
