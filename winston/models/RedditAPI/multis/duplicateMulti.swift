//
//  duplicateMulti.swift
//  winston
//
//  Created by Igor Marcossi on 20/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func duplicateMulti(from: String, to: String) async -> Bool? {
    if let myName = me?.data?.name {
      let params = ["from":"/user/\(myName)/m/\(from)","to":"/user/\(myName)/m/\(to)"]
      switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/multi/copy", method: .post, params: params) {
      case .success:
        return true
      case .failure:
        //        print(error)
        return nil
      }
    }
    return nil
  }
}
