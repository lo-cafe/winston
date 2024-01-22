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
    let params = FetchInboxPayload()
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/message/inbox.json", method: .get, params: params, paramsLocation: .queryString, decodable: Listing<MessageData>.self) {
    case .success(let data):
      return data.data?.children?.map { $0.data }.compactMap { $0 }
    case .failure(let error):
      print(error)
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
    var raw_json = 1
  }
}
