//
//  fetchSubs.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire
import Defaults

extension RedditAPI {
  func fetchSubs() async -> Void {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      
      let params = ["limit": 100, "count": 0]
      
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/subreddits/mine/subscriber.json",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<SubredditData>.self).response
      switch response.result {
      case .success(let data):
        if let modhash = data.data?.modhash {
          loggedUser.modhash = modhash
        }
        await MainActor.run {
          if let children = data.data?.children {
            Defaults[.subreddits] = children
          }
        }
        return
      case .failure(let error):
        print(error)
        return
      }
    } else {
      return
    }
  }
  
  struct FetchSubsPayload: Codable {
    var limit: Int
    var count: Int
    var after: String?
  }
}
