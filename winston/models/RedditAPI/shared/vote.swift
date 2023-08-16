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
    await refreshToken()
    //    await getModHash()
    if let headers = self.getRequestHeaders() {
      let params = VotePayload(dir: action.rawValue, id: id)
      let dataTask = AF.request(
        "\(RedditAPI.redditApiURLBase)/api/vote",
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
  
  struct VotePayload: Codable {
    let dir: Int
    let id: String
    var rank = 2
    //    let uh: String
  }
  
  enum VoteAction: Int, Codable {
    case up = 1
    case none = 0
    case down = -1
    
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
