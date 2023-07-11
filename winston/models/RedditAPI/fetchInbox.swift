//
//  fetchInbox.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func fetchInbox() async -> [MessageData]? {
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = FetchInboxPayload()
      let response = await AF.request(
        "\(RedditAPI.redditApiURLBase)/message/inbox.json",
        method: .get,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .queryString),
        headers: headers
      )
        .serializingDecodable(Listing<MessageData>.self).response
      switch response.result {
      case .success(let data):
        return data.data?.children?.map { $0.data }.compactMap { $0 }
      case .failure(let error):
        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  
  
  struct FetchInboxPayload: Codable {
    var mark = "true"
    var count = 0
    var after = ""
    var before = ""
    var limit = 25
    var show = "all"
    var sr_detail = 1
  }
}
