//
//  search_subreddits.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func searchSubreddits(_ query: String) async -> [SubredditData]? {
    let params = SearchSubredditPayload(q: query)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/subreddits/search", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<SubredditData>.self)  {
    case .success(let data):
      return data.data?.children?.compactMap { $0.data }
    case .failure(let error):
      print(error)
      return nil
    }
  }
  
  struct SearchSubredditPayload: Codable {
    var count = 10
    var limit = 25
    var show = "all"
    var q: String
    var search_query_id = UUID().uuidString
    var typeahead_active = true
    var sr_detail = true
    var sort = "relevance"
    var raw_json = 1
  }
}

