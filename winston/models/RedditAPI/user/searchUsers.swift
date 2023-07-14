//
//  searchUsers.swift
//  winston
//
//  Created by Igor Marcossi on 11/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func searchUsers(_ query: String) async -> [UserData]? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = SearchUserPayload(q: query)
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/users/search",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<Either<UserData, BannedUser>>.self).result
      switch response {
      case .success(let data):
        var result: [UserData] = []
        data.data?.children?.forEach({ x in
          switch x.data {
          case .first(let el):
            result.append(el)
          case .second(_):
            break
          case .none:
            break
          }
        })
        return result
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct BannedUser: Codable, Hashable {
    let is_suspended: Bool?
    let is_blocked: Bool?
    let name: String?
  }
  
  struct SearchUserPayload: Codable {
    var count = 10
    var limit = 25
    var show = "all"
    var q: String
    var search_query_id = UUID().uuidString
    var typeahead_active = true
    var sr_detail = true
    var sort = "relevance"
  }
}
