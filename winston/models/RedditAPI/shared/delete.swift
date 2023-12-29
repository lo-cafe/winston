//
//  deleteComment.swift
//  winston
//
//  Created by Igor Marcossi on 15/08/23.
//

import Foundation
import Alamofire

extension RedditAPI {
  func delete(fullname: String) async -> Bool? {
    let params = ["id": fullname]
    switch await self.doRequest("\(RedditAPI.redditApiURLBase)/api/del", method: .post, params: params)  {
    case .success:
      return true
    case .failure:
      return nil
    }
  }
}
