//
//  fetchMe.swift
//  winston
//
//  Created by Igor Marcossi on 01/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchMe(force: Bool = false) async -> User? {
    if !force, let me = me {
      return me
    }
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/v1/me",
        method: .get,
        headers: headers
      )
        .serializingDecodable(UserData.self).response
      switch response.result {
      case .success(let data):
        await MainActor.run {
          me = User(data: data, api: self)
        }
        return me
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
