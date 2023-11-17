//
//  fetchPopularSubs.swift
//  winston
//
//  Created by Daniel Inama on 19/10/23.
//

import Foundation
import Alamofire
import CoreData

extension RedditAPI {
  func fetchPopularSubs(after: String? = nil) async -> [ListingChild<SubredditData>]? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      
      var params = FetchSubsPayload(limit: 100)
      
      if let after = after {
        params.after = after
      }
      
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/subreddits/popular.json",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<SubredditData>.self).response
      switch response.result {
      case .success(let data):
        print("Fetching success")
        var finalSubs: [ListingChild<SubredditData>] = []
        if let fetchedSubs = data.data?.children {
          finalSubs += fetchedSubs
        }
        return finalSubs
        
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
