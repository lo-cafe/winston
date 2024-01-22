//
//  readMessage.swift
//  winston
//
//  Created by Igor Marcossi on 10/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func readMessage(_ fullname: String) async -> Bool? {
    let params = ReadMessagePayload(id: fullname)
    let result = await self.doRequest("\(RedditAPI.redditApiURLBase)/api/read_message?raw_json=1", method: .post, params: params)
    switch result {
    case .success:
      return true
    case .failure:
      return nil
    }
  }
  
  struct ReadMessagePayload: Codable {
    var id: String
  }
}
