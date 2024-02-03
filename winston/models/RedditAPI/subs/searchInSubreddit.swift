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
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/r/\(subreddit)/search", method: .get, params: advanced, paramsLocation: .queryString, decodable: Listing<UserData>.self)  {
    case .success(let data):
      return data.data?.children?.compactMap { $0.data }
    case .failure(_):
      return nil
    }
  }
  
 
  struct AdvancedPostsSearch: Encodable {
    let subreddit: String
    var flairs: [String]?
    var searchQuery: String?
    var restrictSr: String
    var sort: String
    var time: String
    var limit: String
    
    enum CodingKeys: String, CodingKey {
      case searchQuery = "q"
      case restrictSr = "restrict_sr"
      case sort
      case time = "t"
      case limit
    }
    
    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      
      // Consolidating flairs and searchQuery into `q` parameter as a query string
      var queryItems: [String] = []
      if let flairs = flairs {
        let flairQueries = flairs.map { "flair:\"\($0)\"" }
        queryItems.append(contentsOf: flairQueries)
      }
      if let searchQuery = searchQuery {
        queryItems.append(searchQuery)
      }
      let queryString = queryItems.joined(separator: " OR ")
      try container.encode(queryString, forKey: .searchQuery)
      
      try container.encode(restrictSr, forKey: .restrictSr)
      try container.encode(sort, forKey: .sort)
      try container.encode(time, forKey: .time)
      try container.encode(limit, forKey: .limit)
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
