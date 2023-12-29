//
//  newReply.swift
//  winston
//
//  Created by Igor Marcossi on 04/07/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func newReply(_ message: String, _ destinationID: String) async -> Bool? {
    let params = NewReplyPayload(text: message, thing_id: destinationID)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/comment", method: .post, params: params)  {
    case .success:
      return true
    case .failure:
      //        print(error)
      return nil
    }
  }
  
  struct NewReplyPayload: Codable {
    var api_type = "json"
    let text: String
    var thing_id: String
  }
}
