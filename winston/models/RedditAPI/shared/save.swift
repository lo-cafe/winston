//
//  save.swift
//  winston
//
//  Created by Igor Marcossi on 09/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func save(_ action: Bool, id: String) async -> Bool? {
    let params = SavePayload(id: id)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/\(action ? "save" : "unsave")", method: .post, params: params)  {
    case .success:
      return true
    case .failure:
      return nil
    }
  }
  
  struct SavePayload: Codable {
    let id: String
  }
}
