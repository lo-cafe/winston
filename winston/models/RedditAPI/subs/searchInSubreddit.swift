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
  func searchInSubreddit(_ subreddit: String, _ advanced: AdvancedPostsSearch) async -> [UserData]? {
    let limit = Defaults[.SubredditFeedDefSettings].chunkLoadSize

    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/r/\(subreddit)/search", method: .get, params: advanced.parameters, paramsLocation: .queryString, decodable: Listing<UserData>.self)  {
    case .success(let data):
      return data.data?.children?.compactMap { $0.data }
    case .failure(_):
      return nil
    }
  }
  
  struct AdvancedPostsSearch: Codable {
    let subreddit: String
    let flairs: [String]?
    let searchQuery: String?
    let restrictSr: String
    let sort: String
    let t: String
    var limit: String = "\(Defaults[.SubredditFeedDefSettings].chunkLoadSize)"
    
    var parameters: Codable {
      var params: [String: Any] = [
        "restrict_sr": restrictSr,
        "sort": sort,
        "t": t,
        "limit": limit
      ]
      var query = ""
      if let flairs = self.flairs {
        let flairQuery = flairs.map { "flair:\"\($0)\"" }.joined(separator: " OR ")
        query = flairQuery
      }
      if let searchQ = self.searchQuery {
        if !query.isEmpty { query += " OR " }
        query += searchQ
      }
      params["q"] = query
      
      return params
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
    var raw_json = 1
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
