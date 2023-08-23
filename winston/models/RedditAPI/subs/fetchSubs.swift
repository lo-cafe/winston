//
//  fetchSubs.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation
import Alamofire
import Defaults
import SwiftUI

func cleanSubs(_ subs: [ListingChild<SubredditData>]) -> [ListingChild<SubredditData>] {
  return subs.compactMap({ y in
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

extension RedditAPI {
  func fetchSubs(after: String? = nil) async -> [ListingChild<SubredditData>]? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      
      var params = FetchSubsPayload(limit: 100)
      
      if let after = after {
        params.after = after
      }
      
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
        var finalSubs: [ListingChild<SubredditData>] = []
        if let dataAfter = data.data?.after, !dataAfter.isEmpty, let extraFetchedSubs = await fetchSubs(after: dataAfter) {
          finalSubs += extraFetchedSubs
        }
        if let fetchedSubs = data.data?.children {
          finalSubs += fetchedSubs
        }
        if !after.isNil {
          return finalSubs
        }
        await MainActor.run { [finalSubs] in
          withAnimation {
            Defaults[.subreddits] = cleanSubs(finalSubs)
          }
        }
        return nil
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
    var after: String?
//    var show = "all"
    var count = 0
  }
}
