//
//  search_subreddits.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func searchSubreddits(_ query: String) async -> [SearchSubreddit]? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = SearchSubredditPayload(query: query)
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/search_subreddits",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      )
        .serializingDecodable(SearchSubredditResponse.self).result
      switch response {
      case .success(let data):
        return data.subreddits
      case .failure(_):
        return nil
      }
    } else {
      return nil
    }
  }
  
  
  
  struct SearchSubredditResponse: Codable {
    let subreddits: [SearchSubreddit]
  }
  
  struct SearchSubreddit: Codable {
    let active_user_count: Int?
    let icon_img: String?
    let key_color: String?
    let name: String
    let subscriber_count: Int?
    let is_chat_post_feature_enabled: Bool?
    let allow_chat_post_creation: Bool?
    let allow_images: Bool?
  }
  
  struct SearchSubredditPayload: Codable {
    var exact: Bool = false
    var include_over_18 = true
    var include_unadvertisable = false
    var query: String
    var search_query_id = UUID().uuidString
    var typeahead_active = true
  }
}
