//
//  fetchMoreReplies.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchMoreReplies(comments: [String], postFullname: String, sort: CommentSortOption = .confidence, dropFirst: Bool = false) async -> [ListingChild<CommentData>]? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = MoreRepliesPayload(children: comments.joined(separator: ","), link_id: postFullname, sort: sort.rawVal.value)
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/api/morechildren",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      ).serializingDecodable(MoreRepliesResponse.self).response
      switch response.result {
      case .success(let data):
        if let newData = data.json.data?.things {
          return nestComments(Array(newData.dropFirst(dropFirst ? 1 : 0)))
        }
        return nil
      case .failure(_):
        //        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct MoreRepliesPayload: Codable {
    var api_type = "json"
    let children: String
    var depth = 15
    var limit_children = false
    var link_id: String
    var sort: String
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
