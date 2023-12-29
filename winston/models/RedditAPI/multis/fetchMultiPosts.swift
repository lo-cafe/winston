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
    let limit = Defaults[.SubredditFeedDefSettings].chunkLoadSize
    let params = FetchSubsPayload(limit: limit, after: after)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)\(path).json", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<PostData>.self) {
    case .success(let data):
      return (data.data?.children, data.data?.after)
    case .failure(let error):
      print(error)
      return nil
    }
  }
}
