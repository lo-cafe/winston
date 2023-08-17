//
//  edit.swift
//  winston
//
//  Created by Igor Marcossi on 15/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func edit(fullname: String, newText: String) async -> Bool? {
    await refreshToken()
    if let headers = self.getRequestHeaders() {
      let params = EditUserTextPayload(text: newText, thing_id: fullname)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/editusertext",
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
        return nil
      }
    } else {
      return nil
    }
  }
  
  struct EditUserTextPayload: Codable {
    var api_type = "json"
    var text: String
    var thing_id: String
  }
}
