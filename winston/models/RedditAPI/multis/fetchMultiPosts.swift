//
//  fetchMultiPosts.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Alamofire
import Defaults

extension RedditAPI {
  func fetchMultiPosts(path: String, sort: SubListingSortOption = .best, after: String? = nil) async -> ([ListingChild<PostData>]?, String?)? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let limit = Defaults[.feedPostsLoadLimit]
      let params = FetchSubsPayload(limit: limit, after: after)
      
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)\(path).json",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<PostData>.self).response
      switch response.result {
      case .success(let data):
        return (data.data?.children, data.data?.after)
      case .failure(let error):
        Oops.shared.sendError(error)
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
}
