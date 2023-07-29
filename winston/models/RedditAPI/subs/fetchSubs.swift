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
  func fetchSubs(after: String? = nil) async -> String? {
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
        await MainActor.run {
          if let children = data.data?.children {
            Defaults[.subreddits] = children.compactMap({ y in
              var x = y
              x.data?.description = ""
              x.data?.description_html = ""
              x.data?.public_description = ""
              x.data?.public_description_html = ""
              x.data?.submit_text_html = ""
              x.data?.submit_text = ""
              return x
            })
          }
        }
        return data.data?.after
      case .failure(let error):
        Oops.shared.sendError(error)
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct FetchSubsPayload: Codable {
    var limit: Int
    var count: Int
    var after: String?
  }
}
