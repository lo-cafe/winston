//
//  fetchMe.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchMe(force: Bool = false) async {
    if !force, let me = me {
      RedditAPI.shared.me = me
    } else {
      switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/v1/me", method: .get, decodable: UserData.self)  {
      case .success(let data):
        await MainActor.run {
          RedditAPI.shared.me = User(data: data, api: self)
        }
      case .failure(let error):
        print(error)
        await MainActor.run {
          RedditAPI.shared.me = nil
        }
      }
    }
  }
}
