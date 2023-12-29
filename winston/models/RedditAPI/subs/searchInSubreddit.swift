//
//  searchInSubreddit.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import Foundation
import Alamofire
import Defaults

extension RedditAPI {
  func searchInSubreddit(_ subreddit: String, _ query: String) async -> [UserData]? {
    let limit = Defaults[.SubredditFeedDefSettings].chunkLoadSize
    let params = SearchInSubredditPayload(limit: limit, q: query)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/r/\(subreddit)/search", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<UserData>.self)  {
    case .success(let data):
      return data.data?.children?.compactMap { $0.data }
    case .failure(_):
      return nil
    }
  }
  
  struct SearchInSubredditPayload: Codable {
    var count = 10
    var limit = 25
    var show = "all"
    var q: String
    var search_query_id = UUID().uuidString
    var typeahead_active = true
    var sr_detail = true
    var include_facets = true
    var restrict_sr = false
    var sort: SearchInSubredditSort = .relevance
    var type: String = "sr,link,user"
    var category: String = ""
  }
  
  enum SearchInSubredditSort: String, Codable {
    case relevance
    case hot
    case top
    case new
    case comments
  }
  
  enum SearchInSubredditType: String, Codable {
    case sr
    case link
    case user
  }
}
