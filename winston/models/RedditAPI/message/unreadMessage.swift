//
//  unreadMessage.swift
//  winston
//
//  Created by Igor Marcossi on 13/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func unreadMessage(_ fullname: String) async -> Bool? {
    let params = UnreadMessagePayload(id: fullname)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/unread_message", method: .post, params: params) {
    case .success:
      return true
    case .failure:
      return nil
    }
  }
  
  struct UnreadMessagePayload: Codable {
    var id: String
  }
}
