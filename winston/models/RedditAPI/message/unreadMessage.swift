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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = UnreadMessagePayload(id: fullname)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/unread_message",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      )
        .serializingString()
      let result = await dataTask.result
      switch result {
      case .success:
        return true
      case .failure:
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct UnreadMessagePayload: Codable {
    var id: String
  }
}
