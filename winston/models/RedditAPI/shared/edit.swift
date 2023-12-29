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
    let params = EditUserTextPayload(text: newText, thing_id: fullname)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/editusertext", method: .post, params: params)  {
    case .success:
      return true
    case .failure:
      return nil
    }
  }
  
  struct EditUserTextPayload: Codable {
    var api_type = "json"
    var text: String
    var thing_id: String
  }
}
