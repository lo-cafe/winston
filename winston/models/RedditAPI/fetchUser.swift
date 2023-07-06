//
//  fetchUser.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchUser(_ userName: String) async -> UserData? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let response = await AF.request("\(RedditAPI.redditApiURLBase)/user/\(userName)/about.json",
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
  func fetchUserPublic(_ userName: String) async -> UserData? {
    if let headers = self.getRequestHeaders(includeAuth: false) {
      let response = await AF.request(
        "\(RedditAPI.redditWWWApiURLBase)/user/\(userName)/about.json",
        method: .get,
        headers: headers
      )
        .serializingDecodable(ListingChild<Either<EmptyStruct, UserData>>.self).response
      switch response.result {
      case .success(let data):
        switch data.data {
        case .first(_):
          return nil
        case .second(let userData):
          return userData
        case .none:
          return nil
        }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  struct EmptyStruct: Codable, Hashable {}
}
