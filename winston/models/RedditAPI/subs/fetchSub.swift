//
//  fetchSub.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchSub(_ name: String) async -> ListingChild<SubredditData>? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)\(name.hasPrefix("/r/") ? name : "/r/\(name)/")about.json",
        method: .get,
        headers: headers
      )
        .serializingDecodable(ListingChild<SubredditData>.self).response
      switch response.result {
      case .success(let data):
        return data
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
