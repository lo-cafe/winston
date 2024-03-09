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
  
  func searchInSubreddit(_ subreddit: String?, _ advanced: AdvancedPostsSearch) async -> ([ListingChild<Either<PostData, CommentData>>]?, String?)? {
    var url = "\(RedditAPI.redditApiURLBase)"
    if let subreddit, let subName = SubMetaFormatter(name: subreddit).name {
      url += "/r/\(subName)"
    }
    url += "/search.json"
    print(advanced)
    switch await self.doRequest(url, method: .get, params: advanced, paramsLocation: .queryString, decodable: Listing<Either<PostData, CommentData>>.self)  {
    case .success(let data):
      return (data.data?.children, data.data?.after)
    case .failure(_):
      return nil
    }
  }
  
 
  struct AdvancedPostsSearch: Encodable {
    let subreddit: String
    var flairs: [String]?
    var searchQuery: String
    var restrictSr: String
    var sort: String
    var time: String
    var limit: String
    var after: String
    
    init(after: String? = nil, subreddit: String, flairs: [String]?, searchQuery: String? = nil, restrictSr: String = "true", sortOption: SubListingSortOption, limit: Int = Defaults[.SubredditFeedDefSettings].chunkLoadSize) {
        self.after = after ?? ""
        self.subreddit = subreddit
        self.flairs = flairs
        self.searchQuery = searchQuery ?? "*"
        self.restrictSr = restrictSr
        self.limit = "\(limit)"
        
        switch sortOption {
        case .best, .hot, .new, .controversial:
            self.sort = sortOption.meta.apiValue
            self.time = ""
        case .top(let topOption):
            self.sort = sortOption.meta.apiValue
            self.time = topOption.meta.apiValue
        }
    }
    
    enum CodingKeys: String, CodingKey {
      case after = "after"
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
//      if let searchQuery = searchQuery {
        queryItems.append(searchQuery)
//      }
      let queryString = queryItems.joined(separator: " OR ")
      try container.encode(queryString, forKey: .searchQuery)
      
      try container.encode(after, forKey: .after)
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
