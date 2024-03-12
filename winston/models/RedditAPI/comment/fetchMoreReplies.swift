//
//  fetchMoreReplies.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchMoreReplies(comments: [String], moreID: String, postFullname: String, sort: CommentSortOption = .confidence, dropFirst: Bool = false) async -> [ListingChild<CommentData>]? {
      let params = MoreRepliesPayload(children: comments.joined(separator: ","), link_id: postFullname, sort: sort.rawVal.value, id: moreID)
      switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/morechildren.json", method: .get, params: params, paramsLocation: .queryString, decodable: MoreRepliesResponse.self) {
      case .success(let data):
        return data.json.data?.things
      case .failure(let err):
        print(err)
        return nil
      }
  }
  
  struct MoreRepliesPayload: Codable {
    var api_type = "json"
    let children: String
    var depth = 35
    var limit_children = false
    var link_id: String
    var sort: String
    var id: String = ""
    var raw_json = 1
  }
  
  struct MoreRepliesResponse: Codable {
    let json: MoreRepliesResponseJSON
  }
  
  struct MoreRepliesResponseJSON: Codable {
    let errors: [String]?
    let data: MoreRepliesResponseThings?
  }
  
  struct MoreRepliesResponseThings: Codable {
    let things: [ListingChild<CommentData>]?
  }
}
