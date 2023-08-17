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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = NewReplyPayload(text: message, thing_id: destinationID)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/comment",
        method: .post,
        parameters: params,
        encoder: URLEncodedFormParameterEncoder(destination: .httpBody),
        headers: headers
      ).serializingString()
      let result = await dataTask.result
      switch result {
      case .success:
        return true
      case .failure:
        //        print(error)
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct NewReplyPayload: Codable {
    var api_type = "json"
    let text: String
    var thing_id: String
  }
}
