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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let limit = Defaults[.feedPostsLoadLimit]
      let params = SearchInSubredditPayload(limit: limit, q: query)
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/r/\(subreddit)/search",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<UserData>.self).result
      switch response {
      case .success(let data):
        return data.data?.children?.compactMap { $0.data }
      case .failure(let error):
        return nil
      }
    } else {
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
