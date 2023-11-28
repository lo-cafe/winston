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
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/user/\(userName)/about.json", method: .get, decodable: ListingChild<UserData>.self)  {
    case .success(let data):
      return data.data
    case .failure(let error):
      print(error)
      return nil
    }
  }
  func fetchUserPublic(_ userName: String) async -> UserData? {
    switch await self.doRequest("\(RedditAPI.redditWWWApiURLBase)/user/\(userName)/about.json", authenticated: false, method: .get, decodable: ListingChild<Either<EmptyStruct, UserData>>.self)  {
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
  }
  struct EmptyStruct: Codable, Hashable {}
}
