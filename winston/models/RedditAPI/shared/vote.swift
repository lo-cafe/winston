//
//  vote.swift
//  winston
//
//  Created by Igor Marcossi on 30/06/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func vote(_ action: VoteAction, id: String) async -> Bool? {
    let params = VotePayload(dir: action.rawValue, id: id)
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/vote?raw_json=1", method: .post, params: params)  {
    case .success:
      return true
    case .failure:
      //        print(error)
      return nil
    }
  }
  
  struct VotePayload: Codable {
    let dir: String
    let id: String
//    var rank = 1
    var api_type = "json"
  }
  
  enum VoteAction: String, Codable {
    case up = "1"
    case none = "0"
    case down = "-1"
    
    func boolVersion() -> Bool? {
      switch self {
      case .up:
        return true
      case .none:
        return nil
      case .down:
        return false
      }
    }
  }
}
